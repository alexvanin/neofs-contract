#!/usr/bin/make -f

SHELL=bash
NEOGO?=neo-go

.PHONY: all build sidechain
build: all
all: sidechain mainnet
sidechain: alphabet morph

alphabet_sc = alphabet
morph_sc = audit balance container neofsid netmap proxy reputation
mainnet_sc = neofs processing

define sc_template
$(2)$(1)/$(1)_contract.nef: $(2)$(1)/$(1)_contract.go
	$(NEOGO) contract compile -i $(2)$(1)/$(1)_contract.go -c $(if $(2),$(2),$(1)/)config.yml -m $(2)$(1)/config.json

$(if $(2),$(2)$(1)/$(1)_contract.go: alphabet/alphabet.go alphabet/alphabet.tpl
	go run alphabet/alphabet.go
)
endef

$(foreach sc,$(alphabet_sc),$(eval $(call sc_template,$(sc))))
$(foreach sc,$(morph_sc),$(eval $(call sc_template,$(sc))))
$(foreach sc,$(mainnet_sc),$(eval $(call sc_template,$(sc))))

alphabet: $(foreach sc,$(alphabet_sc),$(sc)/$(sc)_contract.nef)
morph: $(foreach sc,$(morph_sc),$(sc)/$(sc)_contract.nef)
mainnet: $(foreach sc,$(mainnet_sc),$(sc)/$(sc)_contract.nef)

clean:
	find . -name '*.nef' -exec rm -rf {} \;
	find . -name 'config.json' -exec rm -rf {} \;

mr_proper: clean
	for sc in $(alphabet_sc); do\
	  rm -rf alphabet/$$sc; \
	done
