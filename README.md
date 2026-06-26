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
# ProxyJump: the agent authenticates every hop locally; nothing is forwarded
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519 ephemeral-ssh-agent.sh -J bastion.example.com target.example.com

# Agent forwarding: expose the agent on the remote so `git pull`, further `ssh`, etc. can use your keys
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519 ephemeral-ssh-agent.sh -A user@bastion.example.com

# Multiple keys
EPHEMERAL_SSH_AGENT_KEYS=~/.ssh/id_ed25519,~/.ssh/work_key ephemeral-ssh-agent.sh -J bastion.example.com target.example.com
```

## Dependencies

- bash
- ssh-agent (OpenSSH)

## Design Decisions

### Why not persist the agent?

An ephemeral agent only needs to live as long as a single SSH session. Within that session, the agent is consulted for every local authentication: the target host, and each hop of a `ProxyJump` chain. When you also pass `-A`, the same agent is forwarded so that commands on the remote host (such as `git pull` or a further `ssh`) can use your keys.

All of these are a single SSH session originating from the local PC, so an agent scoped to that session is sufficient. There is nothing to share across sessions, and therefore nothing to keep running afterward.

### Why solve it with ssh-agent alone?

ssh-agent is part of OpenSSH and will exist as long as SSH is in use. Having no external dependencies avoids the risks of tool deprecation, incompatible changes, and maintainer abandonment, resulting in a solution with low maintenance cost that can be used long-term.

## Limitations

- Key paths containing spaces are not supported

## License

This project is licensed under the [MIT License](./LICENSE).
