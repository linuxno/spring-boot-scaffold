spring-boot-scaffold部署文档（Linux） 
======

描述了系统Linux下spring-boot-scaffold部署过程。

## 依赖组件

* jdk1.8+（必选）

## 安装步骤

### 获取安装包

1. 获取应用程序包
   * 获取自动构建完成后的安装包上传 /deploy/server 目录下。

### 解压安装包

1. 解压程序包

解压程序包：spring-boot-scaffold-1.0.0.zip
```bash
[root@/etc/host server]# cd /deploy/server/
[root@/etc/host server]# ls
spring-boot-scaffold-1.0.0.zip
[root@/etc/host server]# unzip spring-boot-scaffold-1.0.0.zip
[root@/etc/host server]# ls
spring-boot-scaffold-1.0.0
```

### 调整配置文件

1. 修改conf/application-prod.yml文件
```
此处为示例
```

## 日常维护

1. 前台启动spring-boot-scaffold
```bash
#cd bin/
#./run.sh start
```

2. 后台启动spring-boot-scaffold

```bash
#cd bin/
#./run.sh daemon
```

3. 关闭spring-boot-scaffold-

```bash
#cd bin/
#./run.sh stop
```
## 注意事项

1. JDK环境需要1.8+
2. 若在Windows环境中打包，需清除Windows编译空格

```bash
#cd bin/
#sed -i -e 's/\r$//' *.sh
```

