# Set the task name
TASK = watch_cron_logs

# Uncomment the correct choice indicating either SKA or TST flight environment
FLIGHT_ENV = SKA

# Set the names of all files that get installed
BIN = watch_cron_logs.pl
DATA = default.config TST.config

include /proj/sot/ska/include/Makefile.FLIGHT

# Define outside data and bin dependencies required for testing,
# i.e. all tools and data required by the task which are NOT 
# created by or internal to the task itself.  These will be copied
# first from the local test directory t/ and if not found from the
# ROOT_FLIGHT area.
#
TEST_DEP = 

# To 'test', first check that the INSTALL root is not the same as the FLIGHT
# root with 'check_install' (defined in Makefile.FLIGHT).  Typically this means
# doing 'setenv TST .'.  Then copy any outside data or bin dependencies into local
# directory via dependency rules defined in Makefile.FLIGHT.  Finally install
# the task, typically in '.'. 

# NO TESTs defined!
test: check_install $(TEST_DEP) install

install:
	cp -p watch_cron_logs3.pl $(SKA_ARCH_OS)/bin/
	chmod +x $(SKA_ARCH_OS)/bin/watch_cron_logs3.pl

clean:
	rm -r bin data doc
