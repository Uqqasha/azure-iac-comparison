## Making RESULT file readable

if [ $1 == 'main' ]; then
    if [ $4 == 'Provision' ]; then
        if [ $5 == 'terraform' ]; then
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4       | $5     | azure        | $6            |" >> $2
            else
                echo "| $3     | $4       | $5     | azure        | $6     |" >> $2
            fi
        elif [ $5 == 'ARM' ]; then
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4       |      $5      | azure        | $6            |" >> $2
            else
                echo "| $3     | $4       |      $5      | azure        | $6     |" >> $2
            fi
        else
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4       |     $5     | azure        | $6            |" >> $2
            else
                echo "| $3     | $4       |     $5     | azure        | $6     |" >> $2
            fi
        fi
    else
        if [ $5 == 'terraform' ]; then
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4     | $5     | azure        | $6            |" >> $2
            else
                echo "| $3     | $4     | $5     | azure        | $6     |" >> $2
            fi
        elif [ $5 == 'ARM' ]; then
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4     |      $5      | azure        | $6            |" >> $2
            else
                echo "| $3     | $4     |      $5      | azure        | $6     |" >> $2
            fi
        else
            if [ $6 == 'EastUS' ]; then
                echo "| $3     | $4     |     $5     | azure        | $6            |" >> $2
            else
                echo "| $3     | $4     |     $5     | azure        | $6     |" >> $2
            fi
        fi
    fi
fi