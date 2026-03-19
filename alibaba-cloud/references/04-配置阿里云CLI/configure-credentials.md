# 在阿里云CLI中配置身份凭证

更新时间：2025-09-10 11:30:38

在使用阿里云CLI之前，您需要配置调用阿里云资源所需的凭证信息、地域、语言等。

**说明**

配置凭证时请确保凭证信息的准确性，以防因误操作或接口调用失败导致不必要的损失。

## 身份凭证配置方式

阿里云CLI提供交互式配置和非交互式配置两种配置方式。交互式配置为用户提供了流程引导，使用户能以较低的学习成本在阿里云CLI中快速配置身份凭证。

### 交互式配置

#### 通用语法

调用aliyun configure命令，可使用交互式方式配置凭证。命令语法如下：

```
aliyun configure [--profile <PROFILE_NAME>] [--mode <AUTHENTICATE_MODE>]
```

选项详情：

- PROFILE_NAME：配置名称。如果指定的配置已存在，则修改已存在配置；若不存在，则创建新配置。若不指定，将修改当前配置。当前设置的修改方式，请参见凭证管理。
- AUTHENTICATE_MODE：身份凭证类型，默认使用AK类型。

配置成功的返回示例：

```
Configure Done!!!
..............888888888888888888888 ........=8888888888888888888D=..............
...........88888888888888888888888 ..........D8888888888888888888888I...........
.........,8888888888888ZI: ...........................=Z88D8888888888D..........
.........+88888888 ..........................................88888888D..........
.........+88888888 .......Welcome to use Alibaba Cloud.......O8888888D..........
.........+88888888 ............. ************* ..............O8888888D..........
.........+88888888 .... Command Line Interface(Reloaded) ....O8888888D..........
.........+88888888...........................................88888888D..........
..........D888888888888DO+. ..........................?ND888888888888D..........
...........O8888888888888888888888...........D8888888888888888888888=...........
............ .:D8888888888888888888.........78888888888888888888O ..............
```

### 非交互式配置

#### 通用语法

调用aliyun configure set命令，可使用非交互式方式配置凭证，命令语法如下：

```
aliyun configure set [--profile <PROFILE_NAME>] [--mode <AUTHENTICATE_MODE>] [--settingName <SETTING_VALUE>...]
```

选项详情：

- PROFILE_NAME：指定配置名称。如果指定的配置存在，则修改配置。若不存在，则创建配置。
- AUTHENTICATE_MODE：指定配置的凭证类型，默认为AK类型。更多关于支持类型的详细信息，请参见身份凭证类型。
- SETTING_VALUE：不同类型凭证所需信息不同，详情请参见身份凭证类型及非交互式创建或修改配置。

使用非交互式配置方式配置凭证后可使用aliyun configure list或aliyun configure get命令查看配置是否创建成功。

## 身份凭证类型

阿里云CLI提供以下凭证类型，您可根据实际需求自行配置。

| 凭证类型 | 凭证刷新策略 | 是否支持免密钥访问 |
|---------|-------------|------------------|
| AK | 手动刷新 | 不支持 |
| StsToken | 手动刷新 | 不支持 |
| RamRoleArn | 自动刷新 | 不支持 |
| EcsRamRole | 自动刷新 | 支持 |
| External | 外部系统刷新 | 支持 |
| ChainableRamRoleArn | 遵循前置凭证刷新策略 | 支持 |
| CredentialsURI | 外部系统刷新 | 支持 |
| OIDC | 自动刷新 | 支持 |
| CloudSSO | 需通过浏览器登录 | 支持 |
| OAuth | 首次授权需浏览器交互，后续可自动刷新 | 支持 |

### AK

#### 凭证说明

**重要**

为保证账号安全，建议您创建专用于API访问的RAM用户并创建对应的AccessKey。更多关于凭据的安全使用建议，请参见凭据的安全使用方案。

- AK类型凭证为默认凭证类型，使用AccessKey信息作为身份凭证。配置AK类型凭证时可以忽略--mode选项。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| AccessKey Id | 您的AccessKey ID。获取方式请参见创建RAM用户的AccessKey。 | yourAccessKeyID |
| AccessKey Secret | 您的AccessKey Secret。获取方式请参见创建RAM用户的AccessKey。 | yourAccessKeySecret |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

参考如下示例，配置AK类型凭证AkProfile。

**交互式配置**

命令示例：

```
aliyun configure --profile AkProfile
```

交互过程示例：

```
Configuring profile 'AkProfile' in 'AK' authenticate mode...
Access Key Id []: <yourAccessKeyID>
Access Key Secret []: <yourAccessKeySecret>
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[AkProfile] ...Done.
```

**非交互式配置**

命令示例（Bash）：

```bash
aliyun configure set \
  --profile AkProfile \
  --mode AK \
  --access-key-id <yourAccessKeyID> \
  --access-key-secret <yourAccessKeySecret> \
  --region "cn-hangzhou"
```

命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile AkProfile `
  --mode AK `
  --access-key-id <yourAccessKeyID> `
  --access-key-secret <yourAccessKeySecret> `
  --region "cn-hangzhou"
```

### StsToken

#### 凭证说明

- 阿里云STS（Security Token Service）是阿里云提供的一种临时访问权限管理服务。有关STS Token的更多信息，请参见什么是STS。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| AccessKey Id | 您的临时AccessKey ID。 | STS.L4aBSCSJVMuKg5U1**** |
| AccessKey Secret | 您的临时AccessKey Secret。 | yourAccessKeySecret |
| STS Token | 您的临时STS Token。 | yourSecurityToken |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

参考如下示例，配置StsToken类型凭证StsProfile。

**交互式配置**

配置命令示例如下：

```
aliyun configure --profile StsProfile --mode StsToken
```

交互过程示例如下：

```
Configuring profile 'StsProfile' in 'StsToken' authenticate mode...
Access Key Id []: STS.L4aBSCSJVMuKg5U1****
Access Key Secret []: <yourAccessKeySecret>
Sts Token []: <yourSecurityToken>
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[StsProfile] ...Done.
```

**非交互式配置**

配置命令示例如下（Bash）：

```bash
aliyun configure set \
  --profile StsProfile \
  --mode StsToken \
  --access-key-id "STS.L4aBSCSJVMuKg5U1****" \
  --access-key-secret <yourAccessKeySecret> \
  --sts-token <yourSecurityToken> \
  --region "cn-hangzhou"
```

配置命令示例如下（PowerShell）：

```powershell
aliyun configure set `
  --profile StsProfile `
  --mode StsToken `
  --access-key-id "STS.L4aBSCSJVMuKg5U1****" `
  --access-key-secret <yourAccessKeySecret> `
  --sts-token <yourSecurityToken> `
  --region "cn-hangzhou"
```

### RamRoleArn

#### 凭证说明

**说明**

阿里云CLI自v3.0.276版本起，在RamRoleArn类型凭证中引入对External Id的支持。详情请参见凭证参数说明。

- RamRoleArn类型凭证通过使用RAM用户调用STS服务的AssumeRole接口获取临时身份凭证（STS Token）。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| AccessKey Id | 您的AccessKey ID。获取方式请参见创建RAM用户的AccessKey。 | yourAccessKeyID |
| AccessKey Secret | 您的AccessKey Secret。获取方式请参见创建RAM用户的AccessKey。 | yourAccessKeySecret |
| STS Region | 获取STS Token令牌时发起调用的地域。STS服务支持的地域，请参见服务接入点。 | cn-hangzhou |
| Ram Role Arn | 需要扮演的RAM角色ARN。该角色是可信实体为阿里云账号类型的RAM角色。更多信息，请参见创建可信实体为阿里云账号的RAM角色或CreateRole。您可以通过RAM控制台或API查看角色ARN。 | acs:ram::012345678910****:role/Alice |
| Role Session Name | 角色会话名称。该参数为用户自定义参数。通常设置为调用该API的用户身份，例如：用户名。在操作审计日志中，即使是同一个RAM角色执行的操作，也可以根据不同的RoleSessionName来区分实际操作者，以实现用户级别的访问审计。长度为2~64个字符，可包含英文字母、数字和特殊字符.@-_。 | alice |
| External Id | 角色外部ID。该参数为外部提供的用于表示角色的参数信息，主要功能是防止混淆代理人问题。更多信息，请参见使用ExternalId防止混淆代理人问题。长度为2~1224个字符，可包含英文字母、数字和特殊字符=,.@:/-_。正则为：[\w+=,.@:\/-]*。 | abcd1234 |
| Expired Seconds | 凭证失效时间，单位：秒。该参数默认值为900，最大值为要扮演角色的MaxSessionDuration时间。 | 900 |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

参考如下示例，配置RamRoleArn类型凭证RamRoleArnProfile。

**交互式配置**

命令示例：

```
aliyun configure --profile RamRoleArnProfile --mode RamRoleArn
```

交互过程示例：

```
Configuring profile 'RamRoleArnProfile' in 'RamRoleArn' authenticate mode...
Access Key Id []: <yourAccessKeyID>
Access Key Secret []: <yourAccessKeySecret>
Sts Region []: cn-hangzhou
Ram Role Arn []: acs:ram::012345678910****:role/Alice
Role Session Name []: alice
External ID []: abcd1234
Expired Seconds [900]: 900
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[RamRoleArnProfile] ...Done.
```

**非交互式配置**

命令示例（Bash）：

```bash
aliyun configure set \
  --profile RamRoleArnProfile \
  --mode RamRoleArn \
  --access-key-id <yourAccessKeyID> \
  --access-key-secret <yourAccessKeySecret> \
  --sts-region "cn-hangzhou" \
  --ram-role-arn "acs:ram::012345678910****:role/Alice" \
  --role-session-name "alice" \
  --external-id "abcd1234" \
  --expired-seconds 900 \
  --region "cn-hangzhou"
```

命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile RamRoleArnProfile `
  --mode RamRoleArn `
  --access-key-id <yourAccessKeyID> `
  --access-key-secret <yourAccessKeySecret> `
  --sts-region "cn-hangzhou" `
  --ram-role-arn "acs:ram::012345678910****:role/Alice" `
  --role-session-name "alice" `
  --external-id "abcd1234" `
  --expired-seconds 900 `
  --region "cn-hangzhou"
```

### EcsRamRole

#### 凭证说明

**说明**

- 阿里云CLI自v3.0.225版本起，支持默认使用加固模式（IMDSv2）获取访问凭据，建议您在配置该类型凭证前安装最新版本阿里云CLI工具。
- 如何为ECS和ECI实例授予RAM角色，具体操作请参见创建RAM角色并授予给ECS实例和为ECI实例授予实例RAM角色。

- EcsRamRole类型凭证无需配置AccessKey，当您在ECS或ECI实例内部使用阿里云CLI时，可通过访问元数据服务（Meta Data Service）获取RAM角色的临时身份凭证（STS Token）以调用OpenAPI，从而降低AccessKey泄露的风险。
- 实例元数据服务器支持加固模式和普通模式两种访问方式，阿里云CLI默认使用加固模式（IMDSv2）获取访问凭据。若使用加固模式时发生异常，您可以通过设置环境变量ALIBABA_CLOUD_IMDSV1_DISABLED来执行不同的异常处理逻辑，变量值如下：
  - 当值为false（默认值）时，会使用普通模式继续获取访问凭据。
  - 当值为true时，表示只能使用加固模式获取访问凭据，会抛出异常。
- 服务器是否支持IMDSv2，取决于您在服务器中的配置。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| Ecs Ram Role | 授予ECS实例的RAM角色名称。若不指定此参数，程序将自动访问ECS的元数据服务获取RoleName信息，再通过RoleName信息获取凭证，整个过程需发起两次请求。 | ECSAdmin |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

参考如下示例，配置EcsRamRole类型凭证EcsProfile。

**交互式配置**

命令示例：

```
aliyun configure --profile EcsProfile --mode EcsRamRole
```

交互过程示例：

```
Configuring profile 'EcsProfile' in 'EcsRamRole' authenticate mode...
Ecs Ram Role []: ECSAdmin
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[EcsProfile] ...Done.
```

**非交互式配置**

命令示例（Bash）：

```bash
aliyun configure set \
  --profile EcsProfile \
  --mode EcsRamRole \
  --ram-role-name "ECSAdmin" \
  --region "cn-hangzhou"
```

命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile EcsProfile `
  --mode EcsRamRole `
  --ram-role-name "ECSAdmin" `
  --region "cn-hangzhou"
```

### External

#### 凭证说明

- External类型凭证通过外部程序获取凭证数据，阿里云CLI在使用时会执行该程序命令，获取返回结果作为凭证。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| Process Command | 外部程序命令。支持外部程序返回AccessKey和STS Token两种静态凭证。 | acs-sso login --profile sso |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

- 外部程序返回凭证示例：

**AccessKey**

```json
{
  "mode": "AK",
  "access_key_id": "<yourAccessKeyID>",
  "access_key_secret": "<yourAccessKeySecret>"
}
```

**STS Token**

```json
{
  "mode": "StsToken",
  "access_key_id": "<yourAccessKeyID>",
  "access_key_secret": "<yourAccessKeySecret>",
  "sts_token": "<yourSecurityToken>"
}
```

#### 配置示例

参考如下示例，配置External类型凭证ExternalProfile。

**交互式配置**

命令示例：

```
aliyun configure --profile ExternalProfile --mode External
```

交互过程示例：

```
Configuring profile 'ExternalProfile' in 'External' authenticate mode...
Process Command []: acs-sso login --profile sso
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[ExternalProfile] ...Done.
```

**非交互式配置**

命令示例（Bash）：

```bash
aliyun configure set \
  --profile ExternalProfile \
  --mode External \
  --process-command "acs-sso login --profile sso" \
  --region "cn-hangzhou"
```

命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile ExternalProfile `
  --mode External `
  --process-command "acs-sso login --profile sso" `
  --region "cn-hangzhou"
```

### ChainableRamRoleArn

#### 凭证说明

**说明**

阿里云CLI自v3.0.276版本起，在ChainableRamRoleArn类型凭证中引入对External Id的支持。详情请参见凭证参数说明。

- ChainableRamRoleArn类型凭证通过指定一个前置身份凭证配置，从前置配置中获取中间凭证（AccessKey或STS Token），再基于中间凭证完成角色扮演，获取最终的临时身份凭证（STS Token）。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| Source Profile | 源配置名称。在配置ChainableRamRoleArn类型凭证之前，您需要先创建一个前置凭证作为源配置。详情可参见配置示例。 | RamRoleArnProfile |
| STS Region | 获取STS Token令牌时发起调用的地域。STS服务支持的地域，请参见服务接入点。 | cn-hangzhou |
| Ram Role Arn | 需要扮演的RAM角色ARN。该角色是可信实体为阿里云账号类型的RAM角色。更多信息，请参见创建可信实体为阿里云账号的RAM角色或CreateRole。您可以通过RAM控制台或API查看角色ARN。 | acs:ram::012345678910****:role/Alice |
| Role Session Name | 角色会话名称。该参数为用户自定义参数。通常设置为调用该API的用户身份，例如：用户名。在操作审计日志中，即使是同一个RAM角色执行的操作，也可以根据不同的RoleSessionName来区分实际操作者，以实现用户级别的访问审计。长度为2~64个字符，可包含英文字母、数字和特殊字符.@-_。 | alice |
| External Id | 角色外部ID。该参数为外部提供的用于表示角色的参数信息，主要功能是防止混淆代理人问题。更多信息，请参见使用ExternalId防止混淆代理人问题。长度为2~1224个字符，可包含英文字母、数字和特殊字符=,.@:/-_。正则为：[\w+=,.@:\/-]*。 | abcd1234 |
| Expired Seconds | 凭证失效时间，单位：秒。该参数默认值为900，最大值为要扮演角色的MaxSessionDuration时间。 | 900 |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

**说明**

配置ChainableRamRoleArn类型凭证前，需为前置身份凭证对应RAM身份授予系统权限策略AliyunSTSAssumeRoleAccess。

参考如下示例，配置ChainableRamRoleArn类型凭证ChainableProfile，使用RamRoleArn类型凭证RamRoleArnProfile作为前置身份凭证。

**交互式配置**

配置前置身份凭证RamRoleArnProfile，配置流程可参考RamRoleArn类型凭证配置示例。

执行如下命令，配置ChainableRamRoleArn类型凭证ChainableProfile。

```
aliyun configure --profile ChainableProfile --mode ChainableRamRoleArn
```

交互过程示例如下，在Source Profile选项处输入配置名称RamRoleArnProfile以指定前置凭证：

```
Configuring profile 'ChainableProfile' in 'ChainableRamRoleArn' authenticate mode...
Source Profile []: RamRoleArnProfile
Sts Region []: cn-hangzhou
Ram Role Arn []: acs:ram::012345678910****:role/Alice
Role Session Name []: alice
External ID []: abcd1234
Expired Seconds [900]: 900
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[ChainableProfile] ...Done.
```

**非交互式配置**

阿里云CLI自v3.0.298版本起，支持通过执行aliyun configure set命令，以非交互式方式配置ChainableRamRoleArn类型凭证。命令示例（Bash）：

```bash
aliyun configure set \
  --profile ChainableProfile \
  --mode ChainableRamRoleArn \
  --source-profile RamRoleArnProfile \
  --sts-region "cn-hangzhou" \
  --ram-role-arn "acs:ram::012345678910****:role/Alice" \
  --role-session-name "alice" \
  --external-id "abcd1234" \
  --expired-seconds 900 \
  --region "cn-hangzhou"
```

命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile ChainableProfile `
  --mode ChainableRamRoleArn `
  --source-profile RamRoleArnProfile `
  --sts-region "cn-hangzhou" `
  --ram-role-arn "acs:ram::012345678910****:role/Alice" `
  --role-session-name "alice" `
  --external-id "abcd1234" `
  --expired-seconds 900 `
  --region "cn-hangzhou"
```

### CredentialsURI

#### 凭证说明

- CredentialsURI类型凭证通过访问您提供的URI地址获取临时身份凭证（STS Token）以调用OpenAPI。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| CredentialsURI | 本地或远程URI地址。当指定地址无法正常返回HTTP 200响应状态码，或其响应内容的结构不符合预期格式时，阿里云CLI将对该请求按失败情况处理。 | http://credentials.uri/ |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

- URI地址响应结构示例：

```json
{
  "Code": "Success",
  "AccessKeyId": "<yourAccessKeyID>",
  "AccessKeySecret": "<yourAccessKeySecret>",
  "SecurityToken": "<yourSecurityToken>",
  "Expiration": "2006-01-02T15:04:05Z"
}
```

#### 配置示例

参考如下示例，配置CredentialsURI类型凭证URIProfile。

**交互式配置**

命令示例：

```
aliyun configure --profile URIProfile --mode CredentialsURI
```

交互过程示例：

```
Configuring profile 'URIProfile' in 'CredentialsURI' authenticate mode...
Credentials URI []: http://credentials.uri/
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[URIProfile] ...Done.
```

**非交互式配置**

暂不支持使用非交互式方式配置CredentialsURI类型凭证。

### OIDC

#### 凭证说明

- OIDC类型凭证通过调用STS服务的AssumeRoleWithOIDC接口换取绑定角色的临时身份凭证（STS Token）。详情请参见通过RRSA配置ServiceAccount的RAM权限实现Pod权限隔离。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| OIDCProviderARN | OIDC身份提供商的ARN。您可以通过RAM控制台或API查看OIDC身份提供商的ARN，具体如下：RAM控制台：请参见管理OIDC身份提供商。API：请参见GetOIDCProvider或ListOICProviders。 | acs:ram::012345678910****:oidc-provider/TestOidcIdp |
| OIDCTokenFile | OIDC Token文件路径。OIDC Token是由外部IdP签发的OIDC令牌。 | /path/to/oidctoken |
| Ram Role Arn | 需要扮演的RAM角色ARN。您可以通过RAM控制台或API查看角色ARN。 | acs:ram::012345678910****:role/Alice |
| Role Session Name | 角色会话名称。该参数为用户自定义参数。通常设置为调用该API的用户身份，例如：用户名。在操作审计日志中，即使是同一个RAM角色执行的操作，也可以根据不同的RoleSessionName来区分实际操作者，以实现用户级别的访问审计。长度为2~64个字符，可包含英文字母、数字和特殊字符.@-_。 | alice |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

参考如下示例，配置OIDC类型凭证OIDC_Profile。

**交互式配置**

配置命令示例：

```
aliyun configure --profile OIDC_Profile --mode OIDC
```

交互过程示例：

```
Configuring profile 'OIDC_Profile' in 'OIDC' authenticate mode...
OIDC Provider ARN []: acs:ram::012345678910****:oidc-provider/TestOidcIdp
OIDC Token File []: /path/to/oidctoken
RAM Role ARN []: acs:ram::012345678910****:role/Alice
Role Session Name []: alice
Default Region Id []: cn-hangzhou
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: en
Saving profile[OIDC_Profile] ...Done.
```

**非交互式配置**

配置命令示例（Bash）：

```bash
aliyun configure set \
  --profile OIDC_Profile \
  --mode OIDC \
  --oidc-provider-arn "acs:ram::012345678910****:oidc-provider/TestOidcIdp" \
  --oidc-token-file "/path/to/oidctoken" \
  --ram-role-arn "acs:ram::012345678910****:role/Alice" \
  --role-session-name "alice" \
  --region "cn-hangzhou"
```

配置命令示例（PowerShell）：

```powershell
aliyun configure set `
  --profile OIDC_Profile `
  --mode OIDC `
  --oidc-provider-arn "acs:ram::012345678910****:oidc-provider/TestOidcIdp" `
  --oidc-token-file "/path/to/oidctoken" `
  --ram-role-arn "acs:ram::012345678910****:role/Alice" `
  --role-session-name "alice" `
  --region "cn-hangzhou"
```

### CloudSSO

#### 凭证说明

**说明**

阿里云CLI自3.0.271版本起，引入CloudSSO凭证类型以简化用户登录云SSO的操作步骤。旧版本操作方法仍然可用。

- 云SSO提供基于阿里云资源目录RD（Resource Directory）的多账号统一身份管理与访问控制。当您给云SSO用户或用户组授予RD账号的访问配置后，访问配置将在RD账号内部署一个RAM角色。云SSO通过扮演该RAM角色获取临时身份凭证（STS Token）以调用OpenAPI，从而降低AccessKey泄露的风险。
- CloudSSO凭证依赖浏览器登录，需用户交互完成身份认证。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| SignIn Url | 用户登录地址。获取方法：请登录云SSO控制台，在概览页面的右侧获取用户登录URL。 | https://signin-******.alibabacloudsso.com/device/login |
| Account | RD账号。在交互式配置流程中，请根据提示通过输入账号名称前的序号进行选择。在非交互式配置流程中通过传入账号ID进行指定。获取方法：请登录云SSO控制台，在多账号权限管理页面的右侧，获取RD账号UID。 | 012345678910**** |
| Access Configuration | 访问配置。在交互式配置流程中，请根据提示输入配置名称前的序号进行选择。在非交互式配置流程中通过传入配置ID进行指定。获取方法：请登录云SSO控制台，在访问配置页面，获取访问配置ID。 | ac-012345678910abcde**** |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

#### 配置示例

如下示例，配置名为SSOProfile的CloudSSO类型凭证。

**交互式配置**

执行以下命令，开始配置云SSO登录信息。您可以设置多个Profile，通过指定Profile快速切换登录的账号和访问配置。

```
aliyun configure --profile SSOProfile --mode CloudSSO
```

根据提示输入用户登录地址SignIn Url。

```
aliyun configure --profile SSOProfile --mode CloudSSO
CloudSSO Sign In Url []: https://signin-******.alibabacloudsso.com/device/login
```

在弹出的浏览器窗口中，根据界面提示，完成云SSO用户登录，登录成功后请关闭浏览器窗口。

**说明**

如果浏览器窗口未弹出，您可以根据CLI的提示信息，手动复制登录URL（SignIn url）和用户码（User code）完成登录。

提示信息示例：

```
If the browser does not open automatically, use the following URL to complete the login process:

SignIn url: https://signin-****.alibabacloudsso.com/device/code
User code: *********
```

CLI返回登录成功，同时列出您可以访问的RD账号名称，请输入编号选择要访问的RD账号。

```
Now you can login to your account with SSO configuration in the browser.
You have successfully logged in.
Please choose an account:
1. <RD Management Account>
2. AccountName
Please input the account number: 1
```

CLI列出您可以使用的访问配置，请输入编号选择要使用的访问配置。

```
Please choose an access configuration:
1. AccessConfiguration1
2. AccessConfiguration2
Please input the access configuration number: 2
```

指定默认地域。

```
Default Region Id []: cn-hangzhou
```

配置成功后显示Configure Done字样及欢迎信息。

**非交互式配置**

暂不支持。

### OAuth

#### 凭证说明

**说明**

阿里云CLI自v3.0.299版本起，引入OAuth凭证类型。建议您在配置该类型凭证前安装最新版本阿里云CLI工具。

- 首次配置OAuth类型凭证时，阿里云CLI将在访问控制中创建一个第三方OAuth应用。完成授权后阿里云CLI可使用该应用获取代表用户身份的令牌，从而访问云资源。
- OAuth凭证需通过浏览器完成授权流程，且交互所用浏览器与阿里云CLI必须运行在同一设备上。
- 凭证参数：

| 参数名称 | 说明 | 示例值 |
|---------|------|-------|
| OAuth Site Type | 登录站点。默认值：CN。中国站：0/CN。国际站：1/INTL。 | CN |
| Region Id | 默认地域。部分云产品不支持跨地域访问，建议您优先将默认地域设置为已购资源所在地域。 | cn-hangzhou |

- OAuth范围：

| OAuth范围 | OAuth范围描述 |
|----------|--------------|
| openid | 获取RAM用户的OpenID。（OpenID是一个可以唯一代表用户的字符串，但并不包含阿里云UID、用户名等信息。） |
| /internal/ram/usersts | 用于获取STS凭证调用阿里云服务API。 |

#### 配置示例

参考如下示例，配置OAuth类型凭证OAuthProfile。

**交互式配置**

执行以下命令，开始配置OAuth登录信息。

```
aliyun configure --profile OAuthProfile --mode OAuth
```

根据提示输入登录站点OAuth Site Type。

```
aliyun configure --profile OAuthProfile --mode OAuth
Configuring profile 'OAuthProfile' in 'OAuth' authenticate mode...
OAuth Site Type (CN: 0 or INTL: 1, default: CN):
```

- 输入0或CN：设置登录站点为阿里云中国站。
- 输入1或INTL：设置登录站点为阿里云国际站。
- 直接回车：默认选择中国站（CN）。

在弹出的浏览器窗口中，进行授权操作。

**说明**

当前授权需要具有AliyunRAMFullAccess权限的管理员执行，若您不具备权限请联系相关管理员。

如果浏览器窗口未弹出，您可以根据CLI的提示信息，手动复制登录URL（SignIn url）至浏览器中，完成登录和授权操作。

提示信息示例：

```
If the browser does not open automatically, use the following URL to complete the login process:

SignIn url: https://signin.aliyun.com/oauth2/v1/auth?response_type=code&client_id=403818195455774****&redirect_uri=http%3A%2F%2F127.0.0.1%3A12345%2Fcli%2Fcallback&state=EKumS4qOPm11yRx7&code_challenge=BxR9DHWIdKBypPb089N0ekP-C-SAYwLj_jbLU-N****&code_challenge_method=S256
```

首次配置OAuth凭证时，在第三方应用授权页面中单击授权。阿里云CLI将在访问控制中创建一个第三方OAuth应用。

在完成授权操作后，您还需要为此应用分配RAM账号。请单击前往分配，跳转至访问控制产品控制台 > OAuth应用。

在OAuth应用 > 第三方应用中，单击应用offical-cli的应用名称。

在分配页签中单击创建分配，勾选需要登录的RAM账号。单击确定完成分配。

分配完成后需重新发起授权流程，再次访问登录URL（SignIn url）并单击授权。

授权成功后，为阿里云CLI指定默认地域。

```
Default Region Id []: cn-hangzhou
```

配置成功后显示Configure Done字样及欢迎信息。

**非交互式配置**

暂不支持。

## 凭证管理

阿里云CLI支持多套身份凭证的配置和管理。您可以根据实际需求灵活地切换或指定使用特定的凭证配置。

### 设置当前配置

执行以下命令，可将指定配置切换为当前配置：

```
aliyun configure switch --profile <PROFILE_NAME>
```

切换成功后，直到下一次修改前，阿里云CLI都将默认使用该配置中的设置和凭证。

此外，执行aliyun configure set命令成功修改配置后，修改完成的配置将被自动设为当前配置。

### 在命令行中指定配置

在执行CLI命令时，可通过 --profile 选项显式指定使用的配置。此方式具有最高优先级，会覆盖其他任何形式的默认配置。

示例：使用指定配置exampleProfile调用云服务器ECSDescribeInstances接口，获取云服务器ECS实例信息。

```
aliyun ecs DescribeInstances --profile exampleProfile
```

### 更多身份凭证管理命令

阿里云CLI提供configure及其子命令，方便您管理多个身份凭证。您可以使用这些命令进行凭证的添加、删除、修改和查看等操作。更多信息，请参见多凭证管理。

## 凭证配置存储位置

凭证配置文件profile是一个可自定义名称的设置集，所有凭证信息与设置项均以JSON格式存储在config.json文件中。该文件位于您个人用户目录下的.aliyun文件夹中，个人用户目录位置因操作系统而异。

- Windows：C:\Users\<USER_NAME>\.aliyun
- Linux/macOS：/home/<USER_NAME>/.aliyun

## 相关文档

- [配置代理信息](./use-an-http-proxy-server.md)
- [命令自动补全功能](./auto-completion-function.md)
