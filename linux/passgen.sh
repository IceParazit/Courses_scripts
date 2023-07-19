#!/bin/bash

#Переменные
num_passwords=5
password_length=10
charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
help="Этот скрипт генерирует пароли
Данный скрипт использует следующие аргумнты
-l Данным аргументом можно задать требуемую длину пароля
-n Данным аргументом можно задать требуемое количество генерируемых паролей
-h помощь
По умолчанию данный скрипт имеет следующие параметры 
Длина == 10
Количество == 5
Автор данного скрипта - IceParazit"


# Разбор аргументов командной строки
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            shift
            num_passwords=$1
            ;;
        -l)
            shift
            password_length=$1
            ;;
        -h)
            echo "$help"
            exit
            ;;
        *)
            echo "Ошибка: Неизвестный аргумент: $1"
            exit 1
            ;;
    esac
    shift
done

# Функция для генерации случайного пароля
generate_password() {
    # Используем утилиту /dev/urandom для генерации случайных чисел и tr для выбора символов из charset
    tr -dc "$charset" < /dev/urandom | head -c "$password_length"
    echo
}

# Проверить, что введено целое положительное число
re='^[0-9]+$'
if ! [[ $password_length =~ $re ]] || [ $password_length -lt 1 ]; then
    echo "Ошибка: Введите положительное целое число для длины пароля." >&2
    exit 1
fi

# Генерировать пароль и вывести его на экран
for ((i = 0; i < $num_passwords; i++))
do
    generate_password $password_length
done
exit