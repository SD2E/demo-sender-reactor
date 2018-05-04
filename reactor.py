import os
from reactors.utils import Reactor

DEFAULT_RECIPIENT = 'demo-listener'


def main():
    """Send a message to another Reactor"""
    # If invoking message is valid JSON dict, forward it as the message
    r = Reactor()
    m = {'demo': 'sender'}

    if os.environ.get('MSG', None) is not None:
        m = os.environ.get('MSG')

    r.logger.debug("Aliases version {}".format(r.aliases.version))

    r.logger.debug("Message {}".format(m))

    recipient = DEFAULT_RECIPIENT
    if os.environ.get('RECIPIENT', None) is not None:
        recipient = os.environ.get('RECIPIENT')

    # skip aliases module
    actorId = r.settings.linked_reactors[recipient]['id']
    r.logger.debug("Recipient {} has actorId {}".format(recipient, actorId))

    try:
        exec_id = r.send_message(actorId, m, ignoreErrors=False,
                                 retryMaxAttempts=1)
    except Exception as e:
        r.on_failure("Send failure: {}".format(e))
    r.on_success("Sent message {}. Response was exec_id {}".format(
        m, exec_id))


if __name__ == '__main__':
    main()
