# Sender

This Reactor listens for a message and tries to forward it along to another
Reactor. In this specific case, it's the `demo-listener` so that Reactor-to-
Reactor communications can be documented.

## Usage

An instance of Reactor is usable by all SD2 program participants. Its alias is
`demo-sender` and its permissions are set to `EXECUTE` for the `world`
user.

Really, you want to use the code sample presented here to build your own
messaging relationships between Reactors. Here's a trival send example from
this actor's source code:

```python
r = Reactor()
m = r.context.raw_message

try:
    exec_id = r.send_message('demo-listener', m, ignoreErrors=False,
        retryMaxAttempts=3)
except Exception as e:
    r.on_failure("Send failure: {}".format(e))
r.on_success("Sent message {}. Response was exec_id {}".format(
    m, exec_id))
```

