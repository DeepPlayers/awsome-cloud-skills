# 支持CLI的云产品

更新时间：

本文列举了当前支持阿里云CLI的云产品及其对应Code。您也可以通过以下方式获取最新的支持产品信息：

- 执行 `aliyun --help` 命令动态查询支持的产品列表
- 通过 [GitHub仓库](https://raw.githubusercontent.com/aliyun/aliyun-openapi-meta/master/metadatas/products.json) 查看最新支持产品信息

**说明**

本文档内容可能存在一定滞后（最后更新日期：2025-10-31），建议优先通过上述动态方式获取实时信息。

## **数据库**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **NoSQL 数据库** | 云原生多模数据库 Lindorm | hitsdb |
| | 云数据库 HBase | HBase |
| | 云数据库 MongoDB 版 | Dds |
| | 云数据库 Tair（兼容 Redis®） | R-kvstore |
| **关系型数据库** | 云原生分布式数据库 | polardbx |
| | 云数据库 OceanBase 版 | OceanBasePro |
| | 云数据库 PolarDB | polardb |
| | 云数据库 RDS | Rds |
| | 分布式关系型数据库 DRDS | Drds |
| **数据仓库** | 云原生数据仓库 AnalyticDB PostgreSQL版 | gpdb |
| | 云原生数据仓库AnalyticDB MySQL版 | adb |
| | 云数据库 ClickHouse 版 | clickhouse |
| **数据库管理工具** | 数据传输 | Dts |
| | 数据库自治服务 | DAS |
| | 数据灾备 | Dbs |
| | 数据管理 | dms-enterprise |
| | 数据管理 - 数据库网关 | dms-dg |

## **迁移与运维管理**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **云管理** | 云SSO | cloudsso |
| | 安全令牌 | Sts |
| | 操作审计 | Actiontrail |
| | 访问控制 | Ram |
| | 访问控制 身份管理 | Ims |
| | 资源中心 | ResourceCenter |
| | 资源共享 | ResourceSharing |
| | 资源目录 | ResourceDirectoryMaster |
| | 资源管理 | ResourceManager |
| | 配置审计 | Config |
| | 配额中心 | quotas |
| **备份与迁移** | 服务器迁移中心 | smc |
| **运维与监控** | 云监控 | Cms |
| | 系统运维管理 | oos |

## **容器**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **容器服务** | 分布式云容器平台 | adcp |
| | 容器服务Kubernetes版 | CS |
| | 容器镜像服务 | cr |
| | 服务网格 | servicemesh |

## **域名与网站**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **域名与备案服务** | 云解析 | Alidns |
| | 域名服务 | Domain |

## **人工智能与机器学习**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **人工智能平台** | ITag | OpenITag |
| | 人工智能平台 PAI | PaiStudio |
| | 人工智能平台 PAI - AI 工作空间 | AIWorkSpace |
| | 人工智能平台 PAI - 交互式建模 | pai-dsw |
| | 人工智能平台 PAI - 分布式训练（DLC） | pai-dlc |
| | 人工智能平台 PAI - 工作流 | PAIFlow |
| | 人工智能平台 PAI - 数据集加速器 | PAIElasticDatasetAccelerator |
| | 人工智能平台 PAI - 特征平台 | PaiFeatureStore |
| | 人工智能平台 PAI - 用户增长 | PAIPlugin |
| | 人工智能平台PAI-自动机器学习 | paiAutoML |
| | 模型在线服务 EAS | eas |
| **智能客服** | 云联络中心 | CCC |
| | 智能对话分析 | Qualitycheck |
| | 智能对话机器人 | Chatbot |
| **智能搜索与推荐** | 开放搜索-问天引擎 | searchengine |
| **视觉智能** | 视觉智能开放平台-人脸人体 | facebody |
| | 视觉智能开放平台-内容安全 | imageaudit |
| | 视觉智能开放平台-分割抠图 | imageseg |
| | 视觉智能开放平台-商品理解 | goodstech |
| | 视觉智能开放平台-图像生产 | imageenhan |
| | 视觉智能开放平台-图像识别 | imagerecog |
| | 视觉智能开放平台-文字识别 | ocr |
| | 视觉智能开放平台-目标检测 | objectdet |

## **计算**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **Serverless** | Serverless 应用引擎 | sae |
| | 函数计算 | FC-Open |
| | 函数计算3.0 | FC |
| **云服务器** | 云服务器 ECS | Ecs |
| | 弹性伸缩 | Ess |
| | 弹性加速计算实例 | eais |
| | 弹性容器实例 | Eci |
| | 智能计算灵骏 | eflo |
| | 智能计算灵骏-管控 | eflo-controller |
| | 计算巢-服务商侧 | ComputeNestSupplier |
| | 计算巢服务 | ComputeNest |
| **边缘计算** | 边缘节点服务 ENS | Ens |
| **高性能计算** | 弹性高性能计算 | EHPC |

## **大数据计算**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **数据开发与服务** | 大数据开发治理平台 DataWorks | dataworks-public |
| **数据湖** | E-MapReduce | Emr |
| **数据计算与分析** | Elasticsearch | elasticsearch |
| | 云原生大数据计算服务 MaxCompute | MaxCompute |
| | 实时数仓 Hologres | hologram |
| | 实时计算 Flink版 | ververica |
| | 实时计算售卖控制台 | foasconsole |

## **企业服务与云通信**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **企业云服务** | 移动推送 | Push |
| | 能耗宝 | energyExpertExternal |
| **企业办公协同** | 邮件推送 | Dm |

## **网络与CDN**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **CDN** | 全站加速 | dcdn |
| | 内容分发 | Cdn |
| | 安全加速 SCDN | scdn |
| | 边缘安全加速 | ESA |
| **云上网络** | IP地址管理 | VpcIpam |
| | VPC对等连接 | VpcPeer |
| | 专有网络 | Vpc |
| | 云解析 PrivateZone | pvtz |
| | 任播弹性公网IP | Eipanycast |
| | 应用型负载均衡 | Alb |
| | 私网连接 | Privatelink |
| | 网关型负载均衡 | Gwlb |
| | 网络型负载均衡 | Nlb |
| | 负载均衡 | Slb |
| **混合云网络** | 专线网关 | ExpressConnectRouter |
| **跨地域网络** | 云企业网 | Cbn |
| | 全球加速 | Ga |

## **安全**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **业务安全** | 内容安全 | Green |
| | 实人认证服务 | Cloudauth |
| | 风险识别 | saf |
| **云安全** | DDoS防护包 | ddosbgp |
| | Web 应用防火墙 | waf-openapi |
| | 云安全中心 | Sas |
| | 云安全中心（响应编排） | sophonsoar |
| | 云安全中心（威胁分析） | cloud-siem |
| | 云防火墙 | Cloudfw |
| | 办公安全平台 | csas |
| | 新BGP高防IP | ddoscoo |
| **数据安全** | 密钥管理服务 | Kms |
| | 敏感数据保护 | Sddp |
| | 数字证书管理服务（原SSL证书） | cas |
| **身份安全** | 云身份服务 (IDaaS EIAM) | Eiam |
| | 运维安全中心（堡垒机） | Yundun-bastionhost |

## **开发工具**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **API 与工具** | OpenAPI 门户开放服务 | OpenAPIExplorer |
| | 资源编排 | ROS |
| | 云效DevOps | devops |
| **开发与运维** | HTTPDNS | Httpdns |

## **媒体服务**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **媒体处理与内容生产** | 媒体处理 | Mts |
| **视频服务** | 视频点播 | vod |
| | 视频直播 | live |

## **中间件**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **云原生可观测** | 应用实时监控服务ARMS | ARMS |
| **云消息队列** | 云消息队列 Kafka 版 | alikafka |
| | 云消息队列 RocketMQ 4.0 版 | Ons |
| | 云消息队列 RocketMQ 5.0 版 | RocketMQ |
| | 微消息队列 MQTT | OnsMqtt |
| **应用集成** | API 网关 | CloudAPI |
| | 事件总线 | eventbridge |
| | 云原生API 网关 | APIG |
| **微服务工具与平台** | 任务调度SchedulerX | schedulerx2 |
| | 企业级分布式应用服务 | Edas |
| | 微服务引擎 | mse |

## **物联网**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **物联网云服务** | 物联网平台 | Iot |

## **存储**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **基础存储服务** | 块存储 | ebs |
| | 文件存储（NAS/CPFS） | NAS |
| **存储数据服务** | 日志服务 | Sls |
| | 智能媒体管理 | imm |

## **Serverless**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **应用集成** | 云工作流 | fnf |

## **未分类**

| 产品分类 | 产品名称 | 产品Code |
| :--- | :--- | :--- |
| **未分类** | PAI大模型链路追踪评估 | PaiLLMTrace |
| | RAI | RAI |
| | 云原生应用性能评测 | eflo-cnp |
| | 信息查询服务 | IQS |
| | 安全管家运营平台 | mssp |
| | 对象存储服务管理 | OssAdmin |
| | 标签 | Tag |
| | 阿里云 Billing | BssOpenApi |
