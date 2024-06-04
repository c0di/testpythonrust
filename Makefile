.PHONY: build serve dev clean checkout-theme

build:
	zola build

serve:
	zola serve

dev:
	zola build && zola serve

clean:
	rm -rf public

checkout-theme:
	git submodule update --init
