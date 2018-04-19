.PHONY: tests container tests-local tests-reactor tests-deployed
.SILENT: tests container tests-local tests-reactor tests-deployed

clean:
	rm -rf .hypothesis .pytest_cache __pycache__ */__pycache__ tmp.*

container-py3:
	bash tests/run_deploy_with_updates.sh -R -k -F Dockerfile.py3

container:
	bash tests/run_deploy_with_updates.sh -R -k -F Dockerfile

shell:
	bash tests/run_container_tests.sh bash

tests-local: clean
	bash tests/run_container_tests.sh pytest tests -s -vvv

tests-reactor: clean
	bash tests/run_local_message.sh ${RECIPIENT}

tests-deployed: clean
	bash tests/run_deployed_message.sh

tests: tests-local tests-reactor
	true

deploy: clean
	bash tests/run_deploy_with_updates.sh

after: deploy
	bash tests/run_after_deploy.sh
