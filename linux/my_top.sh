#!/bin/bash

#Переменные
proc_name=false
proc_mem=false
proc_state=false
limit=50
help="Этот скрипт генерирует пароли
Данный скрипт использует следующие аргумнты
-s Данным аргументом выводить строку Состояние процесса
-n Данным аргументом выводить строку Имя процецесса 
-m Данным аргументом выводить строку Физическая память
-h помощь
Автор данного скрипта - IceParazit"

# Разбор аргументов командной строки
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -n|--name)
            shift
            proc_name=true
            ;;
        -m|--memory)
            shift
            proc_mem=true
            ;;
        -s|--state)
            shift
            proc_state=true
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
done


# Проверяем, является ли текущий пользователь суперпользователем (root).
if [[ $EUID -eq 1 ]]; then
   echo "Этот скрипт должен быть запущен с правами суперпользователя (root)." 
   exit 1
fi

# Определяем переменную для ограничения количества выводимых строк


while true; do
    clear  # Очищаем экран перед каждым обновлением информации

    # Выводим заголовки столбцов

            
    if [[ "$proc_name" = true && "$proc_mem" = false && "$proc_state" = false ]]; then
        printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" 
        elif [[ "$proc_mem" = true && "$proc_name" = false && "$proc_state" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Физическая память"
        elif [[ "$proc_state" = true && "$proc_name" = false && "$proc_mem" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Состояние"
        elif [[ "$proc_name" = true && "$proc_state" = true && "$proc_mem" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Состояние"
        elif [[ "$proc_name" = true && "$proc_mem" = true && "$proc_state" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Физическая память"
        elif [[ "$proc_mem" = true && "$proc_state" = true && "$proc_name" = false ]] ; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Физическая память" "Состояние"
        elif [[ "$proc_name" = true && "$proc_mem" = true && "$proc_state" = true  ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Физическая память" "Состояние"
        elif [[ "$proc_name" = false && "$proc_mem" = false && "$proc_state" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Физическая память" "Состояние"
    fi


    # Итерируемся по каталогам с информацией о процессах в /proc
    count=0
    for pid_dir in /proc/[0-9]*/; do
        if [[ $count -ge $limit ]]; then
            break
        fi

        pid=$(basename "$pid_dir")

        # Извлекаем информацию о процессе и выводим её в столбцы
        if [[ -r "$pid_dir/status" && -r "$pid_dir/cmdline" && -r "$pid_dir/statm" ]]; then
            name=$(cat "$pid_dir/status" | awk '/^Name:/ {print $2}')
            memory=$(cat "$pid_dir/statm" | awk '{print $2}')
            memory_kb=$((memory * 4))  # Преобразуем страницы в килобайты
            state=$(cat "$pid_dir/status" | awk '/^State:/ {print $2}')
            
    



        if [[ "$proc_name" = true && "$proc_mem" = false && "$proc_state" = false ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" 
            elif [[ "$proc_mem" = true && "$proc_name" = false && "$proc_state" = false ]]; then
                printf "%-10s %-40s %-20s %-10s\n" "$pid" "${memory_kb} KB"
            elif [[ "$proc_state" = true && "$proc_name" = false && "$proc_mem" = false ]]; then
                printf "%-10s %-40s %-20s %-10s\n" "$pid" "$state"
            elif [[ "$proc_name" = true && "$proc_state" = true && "$proc_mem" = false ]]; then
                printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" "$state"
            elif [[ "$proc_name" = true && "$proc_mem" = true && "$proc_state" = false ]]; then
                printf "%-10s %-30s %-20s %-10s\n" "$pid" "$name" "${memory_kb} KB"
            elif [[ "$proc_mem" = true && "$proc_state" = true && "$proc_name" = false ]] ; then
                printf "%-10s %-30s %-10s %-10s\n" "$pid" "${memory_kb} KB" "$state"
            elif [[ "$proc_name" = true && "$proc_mem" = true && "$proc_state" = true  ]]; then
                printf "%-10s %-35s %-15s %-10s\n" "$pid" "$name" "${memory_kb} KB" "$state"
            elif [[ "$proc_name" = false && "$proc_mem" = false && "$proc_state" = false ]]; then
                printf "%-10s %-35s %-15s %-10s\n" "$pid" "$name" "${memory_kb} KB" "$state"
        fi
            ((count++))
        fi
    done

    sleep 2  # Задержка в секундах между обновлениями
done
