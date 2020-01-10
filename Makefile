# Set the task name
TASK = watch_cron_logs

# Set the names of all files that get installed
BIN = watch_cron_logs3.pl

# Define installation PREFIX as the sys.prefix of python in the PATH.
PREFIX = $(shell python -c 'import sys; print(sys.prefix)')

install:
	mkdir -p $(PREFIX)/bin
	rsync --times --cvs-exclude $(BIN) $(PREFIX)/bin/

install_doc:
	mkdir -p $(SKA)/doc/$(TASK)
	pod2html watch_cron_logs3.pl > $(SKA)/doc/$(TASK)/index.html
	rm -f pod2htm?.tmp
