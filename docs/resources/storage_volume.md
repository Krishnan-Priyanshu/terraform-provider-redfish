---
# Copyright (c) 2023 Dell Inc., or its subsidiaries. All Rights Reserved.
#
# Licensed under the Mozilla Public License Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://mozilla.org/MPL/2.0/
#
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

title: "redfish_storage_volume resource"
linkTitle: "redfish_storage_volume"
page_title: "redfish_storage_volume Resource - terraform-provider-redfish"
subcategory: ""
description: |-
  
---

# redfish_storage_volume (Resource)

This Terraform resource is used to configure virtual disks on the iDRAC Server. We can Create, Read, Update, Delete the virtual disks using this resource.


~> **Note:** `capacity_bytes` and `volume_type` attributes cannot be updated.
## Example Usage

variables.tf
```terraform
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

variable "rack1" {
  type = map(object({
    user         = string
    password     = string
    endpoint     = string
    ssl_insecure = bool
  }))
}
```

terraform.tfvars
```terraform
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

rack1 = {
  "my-server-1" = {
    user         = "admin"
    password     = "passw0rd"
    endpoint     = "https://my-server-1.myawesomecompany.org"
    ssl_insecure = true
  },
  "my-server-2" = {
    user         = "admin"
    password     = "passw0rd"
    endpoint     = "https://my-server-2.myawesomecompany.org"
    ssl_insecure = true
  },
}
```

provider.tf
```terraform
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

terraform {
  required_providers {
    redfish = {
      version = "1.0.0"
      source  = "registry.terraform.io/dell/redfish"
    }
  }
}
```

main.tf
```terraform
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

resource "redfish_storage_volume" "volume" {
  for_each = var.rack1

  redfish_server {
    user         = each.value.user
    password     = each.value.password
    endpoint     = each.value.endpoint
    ssl_insecure = each.value.ssl_insecure
  }

  storage_controller_id = "RAID.Integrated.1-1"
  volume_name           = "TerraformVol"
  volume_type           = "NonRedundant"
  // Name of the physical disk on which virtual disk should get created.
  drives = ["Solid State Disk 0:0:1"]
  // Flag stating when to create virtual disk either "Immediate" or "OnReset"
  settings_apply_time = "Immediate"
  // Reset parameters to be applied when upgrade is completed
  reset_type    = "PowerCycle"
  reset_timeout = 100
  // The maximum amount of time to wait for the volume job to be completed
  volume_job_timeout    = 1200
  capacity_bytes        = 1073323222
  optimum_io_size_bytes = 131072
  read_cache_policy     = "AdaptiveReadAhead"
  write_cache_policy    = "UnprotectedWriteBack"
  disk_cache_policy     = "Disabled"

  lifecycle {
    ignore_changes = [
      capacity_bytes,
      volume_type
    ]
  }
}
```

After the successful execution of the above resource block, virtual disk would have been created. It can be verified through state file.

<!-- schema generated by tfplugindocs -->
## Schema

### Required

- `drives` (List of String) This list contains the physical disks names to create the volume within a disk controller
- `redfish_server` (Block List, Min: 1) This list contains the different redfish endpoints to manage (different servers) (see [below for nested schema](#nestedblock--redfish_server))
- `storage_controller_id` (String) This value must be the storage controller ID the user want to manage. I.e: RAID.Integrated.1-1
- `volume_name` (String) This value is the desired name for the volume to be given
- `volume_type` (String) This value specifies the raid level the virtual disk is going to have. Possible values are: NonRedundant (RAID-0), Mirrored (RAID-1), StripedWithParity (RAID-5), SpannedMirrors (RAID-10) or SpannedStripesWithParity (RAID-50)

### Optional

- `capacity_bytes` (Number) capacity_bytes shall contain the size in bytes of the associated volume.
- `disk_cache_policy` (String) disk_cache_policy shall contain a boolean indicator of the disk cache policy for the Volume.
- `optimum_io_size_bytes` (Number) optimum_io_size_bytes shall contain the optimum IO size to use when performing IO on this volume.
- `read_cache_policy` (String) read_cache_policy shall contain a boolean indicator of the read cache policy for the Volume.
- `reset_timeout` (Number) reset_timeout is the time in seconds that the provider waits for the server to be reset(if settings_apply_time is set to "OnReset") before timing out. Default is 120s.
- `reset_type` (String) Reset type allows to choose the type of restart to apply when settings_apply_time is set to "OnReset"Possible values are: "ForceRestart", "GracefulRestart" or "PowerCycle". If not set, "ForceRestart" is the default.
- `settings_apply_time` (String) Flag to make the operation either "Immediate" or "OnReset". By default value is "Immediate"
- `volume_job_timeout` (Number) volume_job_timeout is the time in seconds that the provider waits for the volume job to be completed before timing out.Default is 1200s
- `write_cache_policy` (String) write_cache_policy shall contain a boolean indicator of the write cache policy for the Volume.

### Read-Only

- `id` (String) The ID of this resource.

<a id="nestedblock--redfish_server"></a>
### Nested Schema for `redfish_server`

Required:

- `endpoint` (String) This field is the endpoint where the redfish API is placed

Optional:

- `password` (String) This field is the password related to the user given
- `ssl_insecure` (Boolean) This field indicates if the SSL/TLS certificate must be verified
- `user` (String) This field is the user to login against the redfish API


