.PHONY: build serve clean

build:
	zola build

serve:
	zola serve

clean:
	rm -rf public

