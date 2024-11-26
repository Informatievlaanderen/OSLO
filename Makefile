-include .env
export

VERSION := $(shell cat VERSION)
# PUBLISHED is a file that contains the docker image to publish to. If it doesn't exist, use the default DOCKER_IMAGE which is an enviorment variable in CI
PUBLISHEDIMAGE := $(shell if [ -f PUBLISHED ]; then cat PUBLISHED; else echo $(DOCKER_IMAGE); fi)

prepare:
	echo ${Dpwd} | docker login -u ${DUser} ${Dregistry} --password-stdin
	mkdir -p content/standaarden

fetch-content:
	git clone git@github.com:Informatievlaanderen/OSLO-Standaardenregister.git && \
    cd OSLO-Standaardenregister && \
    git checkout standaarden && \
    ls && \
    cp -R ./content/* ../content/
	rm -rf OSLO-Standaardenregister

# first build-base should have been run
build:
	docker build -f Dockerfile.build --build-arg "VERSION=${VERSION}" -t informatievlaanderen/standaardenregister-run:${VERSION} .

# first build-base should have been run
build-linux:
	docker build --platform=linux/amd64 -f Dockerfile.build --build-arg "VERSION=${VERSION}" -t informatievlaanderen/standaardenregister-run:${VERSION} .

run:
	docker run -d --rm --name standaardenregister -p 3000:3000 informatievlaanderen/standaardenregister-run:${VERSION}

# first build-base should have been run
# Build latest to always contain the most recent information of all the standards inside the /content folder
build-latest:
	docker build -f Dockerfile.build --build-arg "VERSION=${VERSION}" -t informatievlaanderen/standaardenregister-run:latest .

publish:
	docker tag informatievlaanderen/standaardenregister-run:${VERSION} ${PUBLISHEDIMAGE}:${VERSION}
	docker push ${PUBLISHEDIMAGE}:${VERSION}

publish-latest:
	docker tag informatievlaanderen/standaardenregister-run:latest ${PUBLISHEDIMAGE}:latest
	docker push ${PUBLISHEDIMAGE}:latest

cleanup:
	rm -rf OSLO-Standaardenregister
	rm -rf content
