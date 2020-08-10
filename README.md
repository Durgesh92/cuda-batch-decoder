# Setup Process
```
bash setup.sh
```
# start decoder (preload model)

```
nohup bash start_server.sh > decoder.out &
```
# start python api
```
nohup python3 server.py > server.out &
```
