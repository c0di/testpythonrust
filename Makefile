.PHONY: build serve clean

build:
	zola build

serve:
	zola serve

dev:
	zola build && zola serve

clean:
	rm -rf public

