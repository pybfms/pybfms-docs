PYBFMS_DOC:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR:=$(PYBFMS_DOC)/packages
PYTHON:=$(PACKAGES_DIR)/python/bin/python3
SPHINXBUILD:=$(PACKAGES_DIR)/python/bin/sphinx-build
SPHINXOPTS=

BFMS += pybfms_wishbone pybfms_riscv_debug


all : update

link : 
	rm -rf $(PYBFMS_DOC)/doc/source/bfms
	rm -rf $(PYBFMS_DOC)/doc/source/pybfms
	ln -s $(PYBFMS_DOC)/doc/source/pybfms $(PACKAGES_DIR)/pybfms
	mkdir -p $(PYBFMS_DOC)/doc/source/bfms
	for bfm in $(BFMS); do \
		cp -r $(PACKAGES_DIR)/$$bfm $(PYBFMS_DOC)/doc/source/bfms ; \
		rm -rf $(PYBFMS_DOC)/doc/bfms/$$bfm/.git ; \
	done

update : 
	rm -rf $(PYBFMS_DOC)/doc/source/bfms
	rm -rf $(PYBFMS_DOC)/doc/source/pybfms
	mkdir  $(PYBFMS_DOC)/doc/source/pybfms
	cp -r $(PACKAGES_DIR)/pybfms/doc $(PACKAGES_DIR)/pybfms/src $(PYBFMS_DOC)/doc/source/pybfms
	mkdir -p $(PYBFMS_DOC)/doc/source/bfms
	for bfm in $(BFMS); do \
		mkdir $(PYBFMS_DOC)/doc/source/bfms/$$bfm ; \
		cp -r $(PACKAGES_DIR)/$$bfm/doc $(PACKAGES_DIR)/$$bfm/src $(PYBFMS_DOC)/doc/source/bfms/$$bfm ; \
	done

push :
	deleted=`git status | grep deleted | sed -e 's/deleted://g' | wc -l`; \
        if test $$deleted -ne 0; then \
	    git rm `git status | grep deleted | sed -e 's/deleted://g'`; \
	fi
	git add doc
	git status
	no_changes=`git status | grep 'no changes added' | wc -l`; \
	if test $$no_changes -eq 0; then \
		echo "Changes detected"; \
        	git commit -m "Update @ `date +%Y%m%d_%H%M`"; \
		git push; \
	else \
		echo "No changes committed"; \
	fi

latex latexpdf html :
	rm -rf $(PYBFMS_DOC)/build
	mkdir -p $(PYBFMS_DOC)/build
	$(SPHINXBUILD) \
		-M $@ \
		"$(PYBFMS_DOC)/doc/source" \
		"$(PYBFMS_DOC)/build" \
		$(SPHINXOPTS) 

