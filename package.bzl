# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Package file which defines build_bazel_rules_typescript version in skylark

check_rules_typescript_version can be used in downstream WORKSPACES to check
against a minimum dependent build_bazel_rules_typescript version.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# This version is synced with the version in package.json.
# It will be automatically synced via the npm "version" script
# that is run when running `npm version` during the release
# process. See `Releasing` section in README.md.
VERSION = "0.17.0"

def rules_typescript_dependencies():
    """
    Fetch our transitive dependencies.

    If the user wants to get a different version of these, they can just fetch it
    from their WORKSPACE before calling this function, or not call this function at all.
    """

    # TypeScript compiler runs on node.js runtime
    _maybe(
        http_archive,
        name = "build_bazel_rules_nodejs",
        urls = ["https://github.com/bazelbuild/rules_nodejs/archive/e71fabc3d013981103725afd5d171bb09607c5df.zip"],
        strip_prefix = "rules_nodejs-e71fabc3d013981103725afd5d171bb09607c5df",
        sha256 = "5f0529b68ff6f2fc39efc32b61359508b04a8bb4f57c298b5f3e733e8150c960",
    )

    # ts_web_test depends on the web testing rules to provision browsers.
    _maybe(
        http_archive,
        name = "io_bazel_rules_webtesting",
        urls = ["https://github.com/bazelbuild/rules_webtesting/archive/111d792b9a5b17f87b6e177e274dbbee46094791.zip"],
        strip_prefix = "rules_webtesting-111d792b9a5b17f87b6e177e274dbbee46094791",
        sha256 = "a13af63e928c34eff428d47d31bafeec4e38ee9b6940e70bf2c9cd47184c5c16",
    )

    # ts_devserver depends on the Go rules.
    # See https://github.com/bazelbuild/rules_go#setup for the latest version.
    _maybe(
        http_archive,
        name = "io_bazel_rules_go",
        urls = ["https://github.com/bazelbuild/rules_go/archive/cf571fd7fde8eae4ec621184fe88fdad9b277e31.zip"],
        strip_prefix = "rules_go-cf571fd7fde8eae4ec621184fe88fdad9b277e31",
        sha256 = "12c3f330f5739961a5e57c8b8ac6f0ff9db0794d8081b3781f38d43b187e1098",
    )

    # go_repository is defined in bazel_gazelle
    _maybe(
        http_archive,
        name = "bazel_gazelle",
        urls = ["https://github.com/bazelbuild/bazel-gazelle/archive/976cbaad824ea0ad8a710e047932ffa7c704d63a.zip"],
        strip_prefix = "bazel-gazelle-976cbaad824ea0ad8a710e047932ffa7c704d63a",
        sha256 = "809678e59f195c1f7e2766207bac07abaf6431e5326ce8e415d80e7415b4c100",
    )

    ###############################################
    # Repeat the dependencies of rules_nodejs here!
    # We can't load() from rules_nodejs yet, because we've only just fetched it.
    # But we also don't want to make users load and call the rules_nodejs_dependencies
    # function because we can do that for them, mostly hiding the transitive dependency.
    _maybe(
        http_archive,
        name = "bazel_skylib",
        url = "https://github.com/bazelbuild/bazel-skylib/archive/0.5.0.zip",
        strip_prefix = "bazel-skylib-0.5.0",
        sha256 = "ca4e3b8e4da9266c3a9101c8f4704fe2e20eb5625b2a6a7d2d7d45e3dd4efffd",
    )

def rules_typescript_dev_dependencies():
    """
    Fetch dependencies needed for local development, but not needed by users.

    These are in this file to keep version information in one place, and make the WORKSPACE
    shorter.
    """
    http_archive(
        name = "io_bazel",
        urls = ["https://github.com/bazelbuild/bazel/releases/download/0.9.0/bazel-0.9.0-dist.zip"],
        sha256 = "efb28fed4ffcfaee653e0657f6500fc4cbac61e32104f4208da385676e76312a",
    )

    http_archive(
        name = "com_github_bazelbuild_buildtools",
        url = "https://github.com/bazelbuild/buildtools/archive/0.12.0.zip",
        strip_prefix = "buildtools-0.12.0",
        sha256 = "ec495cbd19238c9dc488fd65ca1fee56dcb1a8d6d56ee69a49f2ebe69826c261",
    )

    #############################################
    # Dependencies for generating documentation #
    #############################################

    http_archive(
        name = "io_bazel_rules_sass",
        urls = ["https://github.com/bazelbuild/rules_sass/archive/1.13.4.zip"],
        strip_prefix = "rules_sass-1.13.4",
        sha256 = "5ddde0d3df96978fa537f76e766538c031dee4d29f91a895f4b1345b5e3f9b16",
    )

    http_archive(
        name = "io_bazel_skydoc",
        urls = ["https://github.com/bazelbuild/skydoc/archive/0ef7695c9d70084946a3e99b89ad5a99ede79580.zip"],
        strip_prefix = "skydoc-0ef7695c9d70084946a3e99b89ad5a99ede79580",
        sha256 = "491f9e142b870b18a0ec8eb3d66636eeceabe5f0c73025706c86f91a1a2acb4d",
    )

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
