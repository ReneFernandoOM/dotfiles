#!/usr/bin/env python3

# symlinkd to /usr/local/bin/

import subprocess
import sys
import shlex

ANSIBLE_CONTAINER = "ansible"
ANSIBLE_IMAGE = "docker-ansible:latest"  # Replace with your image

CLUSTERS = {
    "loadtest": "loadtest-cld-aws",
    "webdev": "webdev-cld-aws",
    "qa": "qa-cld-aws",
    "qa2": "qa2-cld-aws",
    "qa3": "qa3-cld-aws",
    "mlperf": "mlperf-cld-aws",
}


def run(cmd, check=True, capture_output=False, inside_container=False):
    """Helper to run shell commands."""
    if inside_container:
        cmd = f"docker exec -it {ANSIBLE_CONTAINER} {cmd}"

    result = subprocess.run(
        shlex.split(cmd),
        check=check,
        stdout=subprocess.PIPE if capture_output else None,
        stderr=subprocess.PIPE if capture_output else None,
        text=True,
    )
    if capture_output:
        return result.stdout.strip()
    return None


def container_running():
    containers = run("docker ps --format '{{.Names}}'", capture_output=True)
    return containers and ANSIBLE_CONTAINER in containers.splitlines()


def container_is_stopped():
    # Returns True if exists but not running
    containers = run("docker ps -a --format '{{.Names}}'", capture_output=True)
    print(f"Containers: {containers}")
    if containers and ANSIBLE_CONTAINER not in containers.splitlines():
        return False
    running = run("docker ps --format '{{.Names}}'", capture_output=True)

    # No containers running
    if not running:
        return True

    return ANSIBLE_CONTAINER not in running.splitlines()


def start_ansible_container():
    if container_running():
        print("Ansible container already running.")
        return

    if container_is_stopped():
        print("Restarting container")
        run(f"docker start {ANSIBLE_CONTAINER}")
        return

    print("Starting ansible container...")
    run(f"docker run -d --name {ANSIBLE_CONTAINER} {ANSIBLE_IMAGE}")


def check_aws_credentials():
    print("Checking AWS credentials inside ansible container...")
    try:
        run("aws s3 ls", inside_container=True)
        print("AWS credentials valid.")
        return True
    except subprocess.CalledProcessError:
        print("AWS credentials invalid or expired.")
        return False


def refresh_aws_credentials():
    print("Refreshing credentials")
    run("aws-auth-okta.py")


def select_cluster_with_fzf():
    try:
        # Prepare the list of cluster keys (friendly names)
        fzf_input = "\n".join(CLUSTERS.keys())

        # Run fzf as a subprocess and pass the input
        result = subprocess.run(
            ["fzf", "--prompt=Select a cluster: "],
            input=fzf_input,
            text=True,
            stdout=subprocess.PIPE,
        )

        selection = result.stdout.strip()
        if not selection:
            print("No cluster selected.")
            sys.exit(1)

        return selection

    except FileNotFoundError:
        print("fzf is not installed or not in PATH.")
        sys.exit(1)


def main():
    if len(sys.argv) > 1:
        friendly_name = sys.argv[1]
        if friendly_name not in CLUSTERS:
            print(
                f"Invalid cluster '{friendly_name}'. Choose from: {', '.join(CLUSTERS.keys())}"
            )
            sys.exit(1)
    else:
        friendly_name = select_cluster_with_fzf()

    selected_cluster = CLUSTERS[friendly_name]
    print(f"Selected cluster: {selected_cluster}")

    start_ansible_container()

    if not check_aws_credentials():
        refresh_aws_credentials()

        # Double-check credentials after refresh
        if not check_aws_credentials():
            print("Failed to validate AWS credentials after refreshing.")
            sys.exit(1)

    run(
        f"commands/update_ecs_service.py internal {selected_cluster} django-app",
        inside_container=True,
    )

    print("Done.")


if __name__ == "__main__":
    main()
