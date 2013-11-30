PROJECT = facebook_listener

CT_SUITES = eunit http

DEPS = cowboy jsx lager
dep_cowboy = pkg://cowboy master
dep_jsx = pkg://jsx master
dep_lager = https://github.com/basho/lager.git master

TEST_DEPS = ct_helper
dep_ct_helper = https://github.com/extend/ct_helper.git master

# Standard targets.
include erlang.mk


# Extra targets.
autobahn: clean clean-deps deps app build-tests
	@mkdir -p logs/
	@$(CT_RUN) -suite autobahn_SUITE
