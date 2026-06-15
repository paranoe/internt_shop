INSERT INTO roles(name)
VALUES ('admin'), ('buyer'), ('seller')
ON CONFLICT DO NOTHING;

INSERT INTO users(role_id, first_name, email, password_hash)
VALUES
(1, 'Admin', 'admin@test.com', '123456');