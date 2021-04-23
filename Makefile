all:
	$(MAKE) -C main

# Create a new part from template.
# Usage example to create new part xyz: make newpart PART=xyz
newpart:
ifndef PART
	$(error PART not defined)
endif
	mkdir $(PART)
	sed 's/template/$(PART)/g' template/template.s >$(PART)/$(PART).s
	sed 's/template/$(PART)/g' template/Makefile >$(PART)/Makefile
	sed 's/template/$(PART)/g' template/gitignore >$(PART)/.gitignore
