from flask import Flask
from flask import request
import os.path  
import json
from os import listdir
from os.path import isfile, join
import subprocess
import time
import os.path
from os import path
import shutil

app = Flask(__name__)
cuda_iterations = 0

@app.route('/decode')
def hello_world():
    entry = time.perf_counter()
    file_path = request.args.get('dir')
    result = {}
    if os.path.isdir(file_path):
        onlyfiles = [f for f in listdir(file_path) if isfile(join(file_path, f))]
        if len(onlyfiles) == 0:
            result["status"] = "fail"
            result["msg"] = "provided directory is empty"
            return json.dumps(result)
        result["status"] = "pass"
        wav_count = 0
        op = open("tmp/wav.scp","w")
        for audio in onlyfiles:
            if '.wav' not in audio:
                continue
            fn = audio.split(".")[0]
            op.write(fn+" "+file_path+"/"+audio+"\n")
            wav_count += 1
        op.close()
        shutil.move("tmp/wav.scp","scp/wav.scp")
        while True:
            if path.exists("scp/wav.scp"):
                continue
            else:
                break
        res = subprocess.run(["bash", "decode_v4.sh"])
        if cuda_iterations == 0:
            skip_limit = 0
        else:
            skip_limit = ( wav_count * cuda_iterations ) - wav_count
        line_count = 0
        final_res = {}
        res_count = 0
        result_list = []
        with open("out/trans","r") as f1:
            for line in f1:
                if line_count >= skip_limit:
                    temp_dic = {}
                    temp_dic["fname"] = line.split(" ")[0].strip()
                    temp_dic["hyp"] = " ".join(line.split(" ")[1:]).strip()
                    #temp_dic["sequence_id"] = res_count
                    result_list.append(temp_dic)
                    res_count += 1
                line_count += 1
        result["results"] = result_list
        result["time"] = time.perf_counter() - entry
    else:
        result["status"] = "fail"
        result["msg"] = "invalid path provided"
    return json.dumps(result)


if __name__ == '__main__':
   app.run(host="0.0.0.0", port=8000, debug=True)
