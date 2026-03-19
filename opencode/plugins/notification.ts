import type { Plugin } from "@opencode-ai/plugin";

const firstNonEmpty = (...values: Array<unknown>): string | null => {
  for (const value of values) {
    if (typeof value === "string" && value.trim().length > 0) {
      return value.trim();
    }
  }

  return null;
};

const basename = (path: string | null | undefined): string | null => {
  if (!path) return null;
  return path.replace(/\/+$/, "").split("/").pop() || null;
};

const truncate = (value: string, maxLength: number): string => {
  if (value.length <= maxLength) return value;
  return `${value.slice(0, Math.max(0, maxLength - 3))}...`;
};

const repoNameFromCommonDir = (commonDir: string | null): string | null => {
  if (!commonDir) return null;

  const normalized = commonDir.replace(/\/+$/, "");
  if (normalized.endsWith("/.git")) {
    return basename(normalized.slice(0, -5));
  }

  return basename(normalized);
};

const resolveGitContext = async (
  $: Parameters<Plugin>[0]["$"],
  worktreePath: string,
): Promise<{ repo: string; branch: string }> => {
  const commonDir = (
    await $`git -C ${worktreePath} rev-parse --path-format=absolute --git-common-dir`
      .nothrow()
      .quiet()
      .text()
  ).trim();

  const branchName = (
    await $`git -C ${worktreePath} branch --show-current`
      .nothrow()
      .quiet()
      .text()
  ).trim();

  return {
    repo: firstNonEmpty(
      repoNameFromCommonDir(commonDir),
      basename(worktreePath),
      "unknown-repo",
    )!,
    branch: firstNonEmpty(branchName, "(detached)")!,
  };
};

const resolveSessionTitle = async (
  client: Parameters<Plugin>[0]["client"],
  directory: string,
  sessionID: string,
): Promise<string> => {
  try {
    const response = await client.session.get({
      path: { id: sessionID },
      query: { directory },
    });
    const session = response.data;

    return firstNonEmpty(session?.title, "Session completed")!;
  } catch {
    return "Session completed";
  }
};

export const NotificationPlugin: Plugin = async ({
  client,
  project,
  $,
  directory,
  worktree,
}) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return;

      const worktreePath = firstNonEmpty(
        worktree,
        directory,
        project.worktree,
        ".",
      );
      const gitContext = await resolveGitContext($, worktreePath!);
      const taskLabel = await resolveSessionTitle(
        client,
        directory,
        event.properties.sessionID,
      );
      const projectLabel = firstNonEmpty(
        basename(directory),
        basename(project.worktree),
        "unknown-project",
      );

      const subtitle = truncate(
        `repo: ${gitContext.repo} | branch: ${gitContext.branch}`,
        110,
      );
      const body = truncate(
        `project: ${projectLabel} | task: ${taskLabel}`,
        220,
      );
      const appleScript = [
        "on run argv",
        "set notificationTitle to item 1 of argv",
        "set notificationSubtitle to item 2 of argv",
        "set notificationBody to item 3 of argv",
        "display notification notificationBody with title notificationTitle subtitle notificationSubtitle",
        "end run",
      ].join("\n");

      await $`osascript -e ${appleScript} "opencode" ${subtitle} ${body}`;
    },
  };
};
