from openstack_refapp import version


def test_version():
    assert version.version_info.package == "openstack-refapp"
