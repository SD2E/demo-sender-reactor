from attrdict import AttrDict
from reactors.utils import Reactor


def main():
    """Send a message to another Reactor"""
    # If invoking message is valid JSON dict, forward it as the message
    r = Reactor()
    print(r.context)

    m = AttrDict(r.context.message_dict)
    try:
        exec_id = r.send_message('demo-listener', m, ignoreErrors=False,
            retryMaxAttempts=3)
    except Exception as e:
        r.on_failure("Send failure: {}".format(e))
    r.on_success("Sent message {}. Response was exec_id {}".format(
        m, exec_id))


if __name__ == '__main__':
    main()
