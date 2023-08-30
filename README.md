# Дипломная работа по профессии «Системный администратор» - Липин Роман

Задание по дипломной работе - https://github.com/netology-code/sys-diplom/tree/diplom-zabbix

Подготовка рабочего места оператора описана в отдельном документе - [operator.md](<operator.md>)

## Оглавление

* [Инфраструктура](#Инфраструктура)
* [Сайт](#Сайт)
* [Мониторинг](#Мониторинг)
* [Логи](#Логи)
* [Сеть](#Сеть)
* [Резервное копирование](#Резервное-копирование)

## Инфраструктура

Для автоматического развертывания инфраструктуры использовался terraform, в конфигурации виртуальных машин подключался файл cloud-init с подготовленными сценариями. В зависимости от типа и назначения виртуальной машины сценарии содержат:
- создание пользователя и указание ключа доступа по SSH
- подключение необходимых репозиториев
- установка необходимых пакетов
- парезапись (замена) файлов конфигураций сервисов
- выполнение команд оболочки

С документацией по работе с cloud-init можно ознакомиться на сайте [cloudinit.readthedocs.io](<https://cloudinit.readthedocs.io/en/latest/>)

В развертывании Ansible не использовался, но его настройка предусмотрена для дальнейшего взаимодействия с виртуальными машинами. Через механизм выходных значений [output values](<https://developer.hashicorp.com/terraform/language/values/outputs>) и функцию [local-exec](<https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec>) локально формируется файл hosts для дальнейшего взаимодействия с инфраструктурой.

## Сайт

Было развернуто 6 виртуальных машин, из них 2 веб сервера в разных зонах:

![01](https://github.com/lipinra/diplom/blob/master/img/01.png)

Создана целевая группа:

![02](https://github.com/lipinra/diplom/blob/master/img/02.png)

Создана группа бэкендов:

![03](https://github.com/lipinra/diplom/blob/master/img/03.png)

Создан HTTP роутер:

![04](https://github.com/lipinra/diplom/blob/master/img/04.png)

Создан балансировщик:

![05](https://github.com/lipinra/diplom/blob/master/img/05.png)

Проведено тестирование балансировщика:

~~~ bash
curl -v 158.160.35.166:80
~~~

![06](https://github.com/lipinra/diplom/blob/master/img/06.png)

## Мониторинг

Развернутая виртуальная машина с zabbix доступна по адресу http://51.250.40.247/

Логин: Admin

Пароль zabbix

Проведена настройка панелей:

![07](https://github.com/lipinra/diplom/blob/master/img/07.png)

## Логи

Развернутая виртуальная машина с kibana доступна по адресу http://51.250.34.180:5601

Проведена настройка отправки логов:

![08](https://github.com/lipinra/diplom/blob/master/img/08.png)

## Сеть

Создана сеть:

![09](https://github.com/lipinra/diplom/blob/master/img/09.png)

Созданы подсети:

![10](https://github.com/lipinra/diplom/blob/master/img/10.png)

Созданы группы безопасности:

![11](https://github.com/lipinra/diplom/blob/master/img/11.png)

## Резервное копирование

Созданы снимки дисков:

![12](https://github.com/lipinra/diplom/blob/master/img/12.png)

Создано расписание снимков:

![13](https://github.com/lipinra/diplom/blob/master/img/13.png)

Раснисание было настроено на 5 дней, т.к. развернуто 6 вирутальных машин, а имеющиеся квоты ограничены 32 дисками:

![14](https://github.com/lipinra/diplom/blob/master/img/14.png)
