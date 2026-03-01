# ephemeral-ssh-agent

A script that launches ssh-agent per SSH connection and automatically destroys it when the connection ends.

## Background

Most ssh-agent usage examples found on the internet involve adding `eval $(ssh-agent)` to `.bashrc` or `.zshrc`. This spawns a new ssh-agent process every time a terminal is opened, and the process persists after the session ends.

Existing solutions such as Keychain take the approach of recording agent connection information to a file and sharing the agent persistently across sessions.

ephemeral-ssh-agent takes the opposite approach. Instead of persisting the agent, it launches a disposable agent for each SSH connection and automatically destroys it when the connection ends. Since there is no process to manage, proliferation does not occur.

## Usage

```
EPHEMERAL_SSH_AGENT_KEYS=<key>[,<key>...] ephemeral-ssh-agent.sh [ssh options] [user@]host
```

### Examples

```
# Single key
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519 ephemeral-ssh-agent.sh user@example.com

# Multiple keys
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519,~/.ssh/work_key ephemeral-ssh-agent.sh user@example.com

# Agent forwarding
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519 ephemeral-ssh-agent.sh -A user@bastion.example.com
```

## Dependencies

- bash
- ssh-agent (OpenSSH)

## Design Decisions

### Why not persist the agent?

ssh-agent is primarily needed for agent forwarding scenarios: connecting from a local PC to a remote server, then using local keys on that remote server to connect to another server or run `git pull`.

In this use case, there is only a single SSH connection from the local PC, and an ephemeral agent is sufficient.

### Why solve it with ssh-agent alone?

ssh-agent is part of OpenSSH and will exist as long as SSH is in use. Having no external dependencies avoids the risks of tool deprecation, incompatible changes, and maintainer abandonment, resulting in a solution with low maintenance cost that can be used long-term.

## Limitations

- Key paths containing spaces are not supported

## License

This project is licensed under the [MIT License](./LICENSE).
