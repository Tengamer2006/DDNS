$TTL 3600
@   IN SOA ddns1.alexten.com. admin.alexten.com. (
        2025111604 ; serial
        3600       ; refresh
        900        ; retry
        604800     ; expire
        3600       ; minimum
)
    IN NS ddns1.alexten.com.
ddns1 IN A 192.168.60.10
