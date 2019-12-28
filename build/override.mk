define overridable
$(if $(filter $(1),$(OVERRIDES)),$(1)-original,$(1))
endef
