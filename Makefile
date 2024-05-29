.PHONY: lint shellcheck mdl setup-udev deploy-betterusbcopy

# defaults
REMOTE_USER = admin
REMOTE_HOST = nas02.local

lint: shellcheck mdl

shellcheck:
	@echo "👷 Validating shell scripts using ShellCheck $$(shellcheck --version | grep -iE "^version" | sed 's/://'):"
	@shellcheck src/betterusbcopy
	@echo "👌 All OK"

mdl:
	@echo "👷 Validating markdown using mdl version $$(mdl --version):"
	@mdl README.md
	@echo "👌 All OK"

deploy: setup-udev deploy-betterusbcopy

setup-udev:
	@echo "👷 Copy src/99-betterusbcopy.rules to /lib/udev/rules.d/99-betterusbcopy.rules on $(REMOTE_HOST)"
	@scp -O ./src/99-betterusbcopy.rules $(REMOTE_USER)@$(REMOTE_HOST):/tmp/99-betterusbcopy.rules
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "sudo mv /tmp/99-betterusbcopy.rules /lib/udev/rules.d/99-betterusbcopy.rules"
	@echo "👷 reload udev that the new rules take effect"
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "sudo udevadm control --reload-rules"
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "sudo udevadm trigger"
	@echo "🎉 All OK"

deploy-betterusbcopy:
	@echo "👷 Copy src/betterusbcopy to /usr/local/bin/betterusbcopy on $(REMOTE_HOST)"
	@scp -O ./src/betterusbcopy $(REMOTE_USER)@$(REMOTE_HOST):/tmp/betterusbcopy
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "sudo mv /tmp/betterusbcopy /usr/local/bin/betterusbcopy"
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "sudo chmod +x /usr/local/bin/betterusbcopy"
	@echo "🎉 All OK"
