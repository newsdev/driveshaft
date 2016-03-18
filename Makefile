all: decrypt startserver

decrypt:
	openssl enc -d -aes-256-cbc -in google.json.enc -out google.json -k $(OPENSSL_ENCRYPTION_PASSWORD)

startserver:
	puma -t 16:16 -p 3000


