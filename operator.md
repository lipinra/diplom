# Подготовка рабочего места оператора

## Оглавление

* [Генерация ключа доступа ssh](#Генерация-ключа-доступа-ssh)
* [Git](#Git)
    * [Установка git](#Установка-git)
    * [Клонирование репозитория git](#Клонирование-репозитория-git)
* [Yandex CLI](#Yandex-CLI)
    * [Установка yandex cli](#Установка-yandex-cli)
    * [Создание профиля yc](#Создание-профиля-yc)
* [Terraform](#Terraform)
    * [Установка terraform](#Установка-terraform)
    * [Настройка terraform](#Настройка-terraform)
* [Ansible](#Ansible)
    * [Установка ansible](#Установка-ansible)
    * [Проверка доступа](#Проверка-доступа)

## Генерация ключа доступа ssh

``` bash
ssh-keygen -t rsa
```

проверка публичной части ключа:

``` bash
cat ~/.ssh/id_rsa.pub
```

## Git

### Установка git

``` bash
sudo add-apt-repository ppa:git-core/ppa && apt update && apt install git
```

проверка версии:

``` bash
git --version
```

### Клонирование репозитория git

``` bash
git clone https://github.com/lipinra/diplom.git
```

## Yandex CLI

### Установка yandex cli

``` bash
sudo wget -O /usr/bin/yc https://storage.yandexcloud.net/yandexcloud-yc/release/0.109.0/linux/amd64/yc && sudo chmod +x /usr/bin/yc
```

проверяем версию после установки:

``` bash
yc -v
```

### Создание профиля yc

Необходимо перейти по ссылке https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb и получить токен доступа.

далее необходимо произвести инициализацию токена:

``` bash
yc init
```

в диалоговом окне необходимо выбрать профиль и указать иные настройки конфигурации.

проверка настроек профиля:

``` bash
yc config list
```

## Terraform

### Установка terraform

``` bash
sudo apt update && sudo apt install unzip wget -y && wget -O terraform.zip https://hashicorp-releases.yandexcloud.net/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip && sudo unzip terraform.zip -d /usr/bin/ && rm terraform.zip && sudo chmod +x /usr/bin/terraform     
```

проверяем версию после установки:

``` bash
terraform -v
```

### Настройка terraform

настраиваем конфигурацию терраформ

``` bash
nano ~/.terraformrc
```

добавляем

``` yaml
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

переходим в каталог с репозиторием:

``` bash
cd ~/diplom/
```

для инициализации провайдеров выполним команду:

``` bash
terraform init
```
далее проверим текущий проект:

``` bash
terraform plan
```

применим конфигурацию:

``` bash
terraform terraform apply
```

## Ansible

### Установка ansible

``` bash
sudo apt install ansible
```

проверяем версию после установки

``` bash
ansible --version
```

### Проверка доступа

проверяем доступ к хостам, используя файл hosts сгенерированный terraform

``` bash
ansible all -m ping --list-hosts
```

