/*
Copyright (c) 2023 Dell Inc., or its subsidiaries. All Rights Reserved.

Licensed under the Mozilla Public License Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://mozilla.org/MPL/2.0/


Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

resource "redfish_virtual_media" "vm" {
  for_each = var.rack1

  redfish_server {
    user         = each.value.user
    password     = each.value.password
    endpoint     = each.value.endpoint
    ssl_insecure = each.value.ssl_insecure
  }
  // Image to be attached to virtual media
  image           = "http://linuxlib.us.dell.com/pub/redhat/RHEL8/8.8/BaseOS/x86_64/iso/RHEL-8.8.0-20230411.3-x86_64-boot.iso"
  transfer_method = "Stream"
  // Network protocol used to fetch the image
  transfer_protocol_type = "HTTP"
  write_protected        = true
}
