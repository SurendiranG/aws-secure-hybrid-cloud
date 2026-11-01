import boto3

ec2 = boto3.client("ec2", region_name="ap-south-1")

print("Checking security groups for SSH open to the world...")
found = False

for sg in ec2.describe_security_groups()["SecurityGroups"]:
    for rule in sg["IpPermissions"]:
        from_port = rule.get("FromPort")
        to_port = rule.get("ToPort")
        protocol = rule.get("IpProtocol")

        # Does this rule cover port 22? (-1 means all traffic)
        covers_22 = protocol == "-1" or (
            from_port is not None and from_port <= 22 <= to_port
        )

        for ip_range in rule.get("IpRanges", []):
            if covers_22 and ip_range["CidrIp"] == "0.0.0.0/0":
                print(f"FINDING: {sg['GroupName']} ({sg['GroupId']}) allows SSH from 0.0.0.0/0")
                found = True

if not found:
    print("No findings.")
print()
print("Checking S3 buckets for Block Public Access...")
s3 = boto3.client("s3")
s3_found = False

for bucket in s3.list_buckets()["Buckets"]:
    name = bucket["Name"]
    try:
        config = s3.get_public_access_block(Bucket=name)["PublicAccessBlockConfiguration"]
        if not all(config.values()):
            print(f"FINDING: {name} has Block Public Access partly off: {config}")
            s3_found = True
    except s3.exceptions.ClientError:
        print(f"FINDING: {name} has no Block Public Access configuration")
        s3_found = True

if not s3_found:
    print("No findings.")
print()
print("Checking IAM users for MFA...")
iam = boto3.client("iam")
iam_found = False

for user in iam.list_users()["Users"]:
    name = user["UserName"]
    mfa_devices = iam.list_mfa_devices(UserName=name)["MFADevices"]
    if not mfa_devices:
        print(f"FINDING: IAM user {name} has no MFA device")
        iam_found = True

if not iam_found:
    print("No findings.")

