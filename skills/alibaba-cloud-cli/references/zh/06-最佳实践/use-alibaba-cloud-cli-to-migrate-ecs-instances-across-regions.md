# 使用阿里云CLI跨地域迁移ECS实例

更新时间：2025-07-18 19:01:36

本文提供一个基于阿里云CLI的操作示例，为您演示如何通过阿里云CLI创建和复制自定义镜像，实现ECS实例的跨地域迁移。该示例仅供参考使用，实际业务场景中可能需要结合多个API灵活组合，具体方案请根据实际需求设计。

## 方案概览

使用阿里云CLI通过自定义镜像跨地域迁移ECS实例数据，大致可分为以下五个步骤：

1. **创建镜像**：为源ECS实例创建自定义镜像，使用该镜像创建的新实例，会包含您已配置的自定义项，省去您重复自定义实例的时间。
2. **复制镜像**：复制镜像后，您可以在目标地域获得不同ID的新镜像，其标签、资源组、加密属性等配置以复制镜像时的输入参数为准。
3. **新建实例**：使用自定义镜像在目标地域中新建目标ECS实例。
4. **检查实例**：检查新创建的目标ECS实例的相关数据情况，确保实例数据迁移后，业务功能仍可流畅运行。
5. **释放资源**：迁移完成后，结合自身的实际需求，可以选择释放或删除源ECS实例的相关资源，避免资源持续产生费用。

## 注意事项

数据迁移前，请您仔细阅读以下注意事项。

- 在创建自定义镜像期间，系统会对ECS实例的各个云盘自动创建快照，快照将产生一定的费用。有关快照费用的详细信息，请参见快照计费。
- 部分包含本地盘的实例无法创建快照，此类实例不支持通过本文的操作完成实例的数据迁移。
- 源ECS实例的网络类型可以是经典网络或专有网络VPC。
- 新建目标ECS实例时，仅支持创建VPC网络类型的ECS实例。
- 新建目标ECS实例时，仅支持选择当前可用区下有库存的实例规格。建议您提前自行做好资源所属地域和可用区的规划工作。
- 由于是通过自定义镜像完成的实例数据迁移操作，因此数据迁移后，新创建的目标ECS实例中云盘数据与源ECS实例中的云盘数据保持一致，但新创建的目标ECS实例的实例元数据会重新生成，与源ECS实例中的实例元数据相比较会发生变化。关于实例元数据的更多信息，请参见实例元数据。
- 由于实例元数据会发生变化，在实例数据迁移之前，建议您手动排查资源关联关系，并在数据迁移后及时更新资源的关联关系。例如：
  - 集群内部通过私网IP地址互联互通，在进行实例数据迁移后，您需要替换为最新的私网IP地址。
  - 某些应用的许可证（License）与ECS实例的MAC地址绑定，在进行实例数据迁移后，这些许可证将因为ECS实例的MAC地址改变而失效，您需要重新绑定最新的MAC地址。
- 如果您要保持公网IP地址不变，且源ECS实例使用的是固定公网IP，可以先将公网IP转换为弹性公网IP（EIP）以保留该公网IP，然后解绑EIP，最后绑定到迁移后的ECS实例上。具体操作，请参见固定公网IP转为弹性公网IP和弹性公网IP。
  - **说明**：如果源ECS实例使用的是弹性公网IP（EIP），迁移后，源ECS实例先解绑EIP，然后绑定到迁移后的ECS实例上。具体操作，请参见弹性公网IP。
- 本地SSD型实例规格不支持创建包含系统盘和数据盘的镜像。更多信息，请参见本地SSD型实例规格族介绍。

## 操作步骤

### 步骤一：为源ECS实例创建自定义镜像

通过实例创建自定义镜像前，您需要了解相关注意事项。更多信息，请参见使用实例创建自定义镜像。

**说明**

为保证数据完整性，建议您停止实例后再进行创建镜像的操作。

执行以下命令，调用CreateImage接口创建源ECS实例的自定义镜像。

```bash
aliyun ecs CreateImage \
  --RegionId 'cn-hangzhou' \
  --ImageName Created_from_hangzhouECS \
  --InstanceId 'i-bp1g6zv0ce8oghu7****'
```

系统返回类似如下结果示例。

```json
{
  "ImageId": "m-bp146shijn7hujku****",
  "RequestId": "C8B26B44-0189-443E-9816-*******"
}
```

执行以下命令，调用DescribeImages接口查询自定义镜像创建状态。确认镜像状态变更为Available后执行下一步骤。

```bash
aliyun ecs DescribeImages \
  --RegionId 'cn-hangzhou' \
  --ImageId 'm-bp146shijn7hujku****' \
  --Status 'Creating,Available' \
  --output cols='ImageId,Status' rows='Images.Image[]' \
  --waiter expr='Images.Image[0].Status' to='Available'
```

### 步骤二：跨地域复制镜像

将源ECS实例的数据跨地域迁移至新创建的目标ECS实例，需要先通过复制镜像功能将自定义镜像复制到其他地域。

执行以下命令，调用CopyImage接口从cn-hangzhou复制源ECS实例的自定义镜像到cn-beijing。

```bash
aliyun ecs CopyImage \
  --RegionId 'cn-hangzhou' \
  --DestinationImageName Copy_from_hangzhouImage \
  --ImageId 'm-bp146shijn7hujku****' \
  --DestinationRegionId 'cn-beijing'
```

返回结果示例。

```json
{
  "ImageId": "m-bp1h46wfpjsjastd****",
  "RequestId": "473469C7-AA6F-4DC5-B3DB-A3DC0DE3C83E"
}
```

执行以下命令，调用DescribeImages接口查询复制镜像创建状态。确认镜像状态变更为Available后执行下一步骤。

```bash
aliyun ecs DescribeImages \
  --RegionId 'cn-beijing' \
  --ImageId 'm-bp1h46wfpjsjastd****' \
  --Status 'Creating,Available' \
  --output cols='ImageId,Status' rows='Images.Image[]' \
  --waiter expr='Images.Image[0].Status' to='Available'
```

### 步骤三：使用自定义镜像新建目标ECS实例

执行以下命令，调用RunInstances接口根据自定义镜像在目标地域创建ECS实例。

**说明**

- 示例命令中PasswordInherit选项设置为true，执行命令创建实例时将使用镜像预设的密码。使用镜像预设密码后，新创建的目标ECS实例登录密码与源ECS实例的登录密码一致。
- 您可根据需求自行选择符合的实例规格，更多参数信息，请参见自定义购买实例。

```bash
aliyun ecs RunInstances \
  --RegionId 'cn-beijing' \
  --SecurityGroupId 'sg-2zea9dbddva****' \
  --VSwitchId 'vsw-2zep7vc25mjc1****' \
  --ImageId 'm-bp1h46wfpjsjastd****' \
  --InstanceType 'ecs.e-c1m1.large' \
  --InstanceName Copy_from_hangzhouECS \
  --PasswordInherit true \
  --InternetChargeType PayByTraffic \
  --SystemDisk.Size 40 \
  --SystemDisk.Category cloud_essd \
  --InstanceChargeType PostPaid \
  --InternetMaxBandwidthOut 10
```

返回结果示例：

```json
{
  "RequestId": "473469C7-AA6F-4DC5-B3DB-A3DC0DE3****",
  "InstanceIdSets": {
    "InstanceIdSet": [
      "i-bp67acfmxazb4pd2****"
    ]
  }
}
```

### 步骤四：检查目标ECS实例内数据

目标ECS实例创建后，您需要检查实例内部相关数据情况，以确保实例数据迁移后，业务功能仍可流畅运行。例如：

- **检查云盘数据**：远程连接新创建的目标ECS实例，检查系统盘数据是否与源ECS实例一致，例如比较文件和目录结构是否一致。如果源ECS实例存在数据盘并在目标ECS实例上挂载了相应的云盘，您可以检查数据盘上的数据是否与源ECS实例一致。
- **运行应用程序或服务**：如果您的源ECS实例上运行了特定的应用程序或服务，您可以尝试在目标ECS实例上运行相同的应用程序或服务，并验证其功能和数据操作是否与源ECS实例一致。
- **对比资源信息变化**：
  - 您可以执行以下命令，调用DescribeInstances，对比源ECS实例与新创建的目标ECS实例相关的资源信息变化，例如镜像信息、网络配置等。

```bash
aliyun ecs DescribeInstances --RegionId 'cn-beijing' --InstanceIds '["i-bp67acfmxazb4pd2****"]'
```

- **更新资源的关联关系**：新创建的目标ECS实例的实例元数据会重新生成，与源ECS实例中的实例元数据相比会发生变化。您需要在数据迁移后及时更新资源的关联关系。更多信息，请参见实例元数据。

### 步骤五：释放或删除源ECS实例及相关资源

在您仔细检查新创建的目标ECS实例与源ECS实例数据没有差异，且完成了资源关联关系的更新，确保新创建的目标ECS实例内业务可以流畅运行后，结合自身的实际需求，可以选择释放或删除源ECS实例的相关资源，避免资源持续产生费用。相关操作说明如下：

**警告**

释放实例、删除镜像以及删除快照的操作为单向操作，一旦操作完成，资源内的数据不可恢复。请确保您已完成所有业务数据的迁移再执行释放或删除资源的操作。

- 您可执行以下命令，调用DeleteInstance接口释放源ECS实例。更多信息，请参见释放实例。

```bash
aliyun ecs DeleteInstance --InstanceId i-bp67acfmxazb4pd2****
```

- 您可执行以下命令，调用DeleteImage接口删除创建的自定义镜像。更多信息，请参见删除自定义镜像。

**重要**

删除自定义镜像后，使用该镜像创建的ECS实例将无法初始化系统盘。如果您的自定义镜像为免费镜像，且您需要保留该镜像以供后续使用，建议无需删除该自定义镜像。有关镜像计费的详细信息，请参见镜像计费。

```bash
aliyun ecs DeleteImage --RegionId 'cn-hangzhou' --ImageId 'm-bp146shijn7hujku****'
```

- 您可执行以下命令，调用DeleteSnapshot接口删除指定的快照。更多信息，请参见删除快照。

```bash
aliyun ecs DeleteSnapshot --SnapshotId 's-bp1c0doj0taqyzzl****'
```

## 脚本示例

阿里云CLI可在命令行脚本中使用，以下简单示例供您参考，您可以在此基础上自行实现异常处理、资源清理等高级功能。

**说明**

运行Bash脚本示例需自行安装jq工具。

## 相关文档

您可在控制台中实现同地域或者跨地域下的ECS实例间的迁移。具体操作，请参见通过自定义镜像跨地域复制ECS实例。
