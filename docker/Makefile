
# Base images the others are based on, usually the platform
PLATFORM_IMAGES := ubuntu1404-ansible


TARGET_IMAGES := catalog-base

$(PLATFORM_IMAGES):
	docker build --tag $@ $@

image: $(PLATFORM_IMAGES)

.PHONY: image $(PLATFORM_IMAGES)
