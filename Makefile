TASK = watch_cron_logs

SKA = /proj/sot/ska
SKA_BIN = $(SKA)/bin
SKA_DATA = $(SKA)/data

install:
	rsync --cvs-exclude --times watch_cron_logs.pl $(SKA_BIN)/
	mkdir -p $(SKA_DATA)/$(TASK)
	rsync --cvs-exclude --times data/* $(SKA_DATA)/$(TASK)/

clean:
	rm -i $(SKA_BIN)/watch_cron_logs.pl
	rm -ri $(SKA_DATA)/$(TASK)
