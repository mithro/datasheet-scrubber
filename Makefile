include conda.mk

init:
	python ./Initializer.py
categorizer:
	python ./test_confusion_matrix.py
extraction:
	python ./Datasheet_Scrubbing.py
clean:
	python ./cleaner.py
