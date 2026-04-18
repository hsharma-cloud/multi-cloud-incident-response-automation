import boto3
import os

ec2 = boto3.client('ec2')

QUARANTINE_SG = os.environ.get("QUARANTINE_SG")

def lambda_handler(event, context):
    print("Event received:", event)

    instance_id = event.get("detail", {}).get("resource", {}).get("instanceDetails", {}).get("instanceId")

    if not instance_id:
        print("No instance found in event")
        return

    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        Groups=[QUARANTINE_SG]
    )

    print(f"Instance {instance_id} isolated")
