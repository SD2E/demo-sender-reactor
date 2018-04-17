# Listener

This Reactor listens for a message and verbosely logs its Reactor context when
it receives one. Importantly, it logs not just the message but all the sender
metadata that `reactors.utils.Reactor.send_message()` decorates inter-actor
messages with.

## Usage

This Reactor is usable by all SD2 program participants. Its alias is
`demo-listener` and its permissions are set to `EXECUTE` for the `world`
user. Here's a trivial example of `reactor.py` code:

```python
from reactors.utils import Reactor

r = Reactor()
exec_id = r.send_message('demo-listener', 'Your plaintext or JSON dict message')
r.logger('demo-listener launched execution id {}'.format(exec_id))
```

