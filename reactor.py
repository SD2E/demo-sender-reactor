from reactors.utils import Reactor

DEFAULT_RECIPIENT = 'demo-listener'


def main():
    """Exercise functions that rely on an API client"""
    r = Reactor()

    profile = r.client.profiles.get()
    r.logger.debug("Profile: {}".format(profile))

    apps_list = []
    apps_list_raw = r.client.apps.list(publicOnly=True)
    for app in apps_list_raw:
        apps_list.append(app.get('id'))
    r.logger.debug("Apps: {}".format(apps_list))

    actors_list = []
    actors_list_raw = r.client.actors.list()
    for actor in actors_list_raw:
        actors_list.append(actor.get('name'))
    r.logger.debug("Actors: {}".format(actors_list))

    aliases = r.aliases.get_aliases()
    r.logger.debug("Aliases: {}".format(aliases))

    if len(aliases) > 0:
        one_alias = r.aliases.get_name(aliases[0])
        r.logger.debug("Alias lookup 1: {} => {}".format(
            aliases[0], one_alias))

    another_alias = r.aliases.get_name('demo-listener')
    r.logger.debug("Alias lookup 2: {} => {}".format(
        'demo-listener', another_alias))

    # r.send_message(actorId=one_alias, message="Message 1",
    #                retryMaxAttempts=2, retryDelay=2)
    r.send_message(actorId='gO0JeWaBM4p3J', message="Message 2",
                   retryMaxAttempts=2, retryDelay=2)


if __name__ == '__main__':
    main()
