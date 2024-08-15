
# convert from safetensor to gguf by llama.cpp
python3 llama.cpp/convert_hf_to_gguf.py 1.hf-pt-models/Llama3-Chinese-8B-Instruct --outfile 2.f16-models

# convert quantized-model to Q5_K_M
cd llama.cpp
./llama-quantize ../2.f16-models/Llama3-Chinese-8B-Instruct-F16.gguf ../3.quantized-models/llama3-chinese:8b.gguf Q5_K_M

# load gguf model on ollama platform
cd ..
mv 3.quantized-models/llama3-chinese:8b.gguf 4.ollama-create/FlagAlpha/
cd 4.ollama-create/FlagAlpha/
ollama create llama3-chinese:8b -f modelfile

# Run “run_ollama_n_k8sgpt.sh” 
cd ~/11.Github/_Lecture_k8s_learning.kit/B/B.005
./run_ollama_n_k8sgpt.sh Chinese -i



# Questions 

Q: 请告诉我更多详细信息

Q: What is the endpoints?

Q: in Chinese

Q: in Korean

