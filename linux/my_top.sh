#!/bin/bash

#Переменные
proc_name=2
proc_mem=2
proc_state=2
limit=40
help="Этот скрипт генерирует пароли
Данный скрипт использует следующие аргумнты
-l Данным аргументом можно задать требуемую длину пароля
-n Данным аргументом можно задать требуемое количество генерируемых паролей
-h помощь
По умолчанию данный скрипт имеет следующие параметры 
Длина -eq 10
Количество -eq 5
Автор данного скрипта - IceParazit"

# Разбор аргументов командной строки
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -l) 
            limit=$1
            shift 2
            ;;
        -n|--name)
            shift
            proc_name="1"
            ;;
        -m|--memory)
            shift
            proc_mem="1"
            ;;
        -s|--state)
            shift
            proc_state="1"
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


# Проверяем, является ли текущий пользователь суперпользователем (root).
if [[ $EUID -eq 1 ]]; then
   echo "Этот скрипт должен быть запущен с правами суперпользователя (root)." 
   exit 1
fi

# Определяем переменную для ограничения количества выводимых строк


while true; do
    clear  # Очищаем экран перед каждым обновлением информации

    # Выводим заголовки столбцов
    if [[ $proc_name -eq 1 && $proc_mem -ne 1 && $proc_state -ne 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" 
        elif [[ $proc_name -ne 1 && $proc_mem -eq 1 && $proc_state -ne 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID"  "Физическая память" 
        elif [[ $proc_name -ne 1 && $proc_mem -ne 1 && $proc_state -eq 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID"  "Состояние"
        elif [[ $proc_name -ne 1 && $proc_mem -eq 1 && $proc_state -eq 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Физическая память" "Состояние"
        elif [[ $proc_name -eq 1 && $proc_mem -ne 1 && $proc_state -eq 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Состояние"
        elif [[ $proc_name -eq 1 && $prmem -eq 1 && $proc_state -ne 1 ]]; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Физическая память"
        elif [[ $proc_name -eq 1 && $proc_mem -eq 1 && $proc_state -eq 1 ]] ; then
            printf "%-10s %-40s %-20s %-10s\n" "PID" "Имя процесса" "Физическая память" "Состояние"
        elif [[ $proc_name -eq 1 && $proc_mem -eq 1 && $proc_state -eq 1  || $proc_name -eq 2 && $proc_mem -eq 2 && $proc_state -eq 2 ]]; then
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
            
            if [[ $proc_name -eq 1 && $proc_mem -ne 1 && $proc_state -ne 1 ]]; then
                printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" 
                elif [[ $proc_name -ne 1 && $proc_mem -eq 1 && $proc_state -ne 1 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "${memory_kb} KB"
                elif [[ $proc_name -ne 1 && $proc_mem -ne 1 && $proc_state -eq 1 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "$state"
                elif [[ $proc_name -ne 1 && $proc_mem -eq 1 && $proc_state -eq 1 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "${memory_kb} KB" "$state"
                elif [[ $proc_name -eq 1 && $proc_mem -ne 1 && $proc_state -eq 1 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" "$state"
                elif [[ $proc_name -eq 1 && $proc_mem -eq 1 && $proc_state -ne 1 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" "${memory_kb} KB"
                elif [[ $proc_name -eq 1 && $proc_mem -eq 1 && $proc_state -eq 1  || $proc_name -eq 2 && $proc_mem -eq 2 && $proc_state -eq 2 ]]; then
                    printf "%-10s %-40s %-20s %-10s\n" "$pid" "$name" "${memory_kb} KB" "$state"
            fi
            ((count++))
        fi
    done

    sleep 2  # Задержка в секундах между обновлениями
done
