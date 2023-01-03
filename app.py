from control_factory import Factory
from controller_control import ControllerControl
from http_control import HTTPControl
from nodered import match_flow


# nodered http post method handler -> payload
def nodered_handler(pid, body, controller, **kwargs) -> dict:
    controller.logger.debug(event='POST', function='nodered_handler', controller=controller, kwargs=kwargs)
    return match_flow(
        requestor_id=pid,
        intent_id=body['intent_id'],
        flow_pattern=body['flow_pattern'],
        flow_class=body['flow_class'],
        flow_quality=body['flow_quality']
    )


# controller prototype
prototype = ControllerControl(name='flow-match')

# http controller for nodered flows
nodered = HTTPControl(name='nodered', loop='closed')
nodered.resource.include_keys = ['label', 'nodes']
nodered.resource.exclude_keys = ['z']
prototype.payload.add(nodered)

# factory api
factory = Factory(load_rest_api=True)
factory.api.info = {
    'title': 'Flow-Match Control',
    'description': 'Flow-Match Controller API'
}

factory.api.add_sections({
    'flows': {
        'v1.0': {
            'input': {
                'properties': {
                    'intent_id': {'example': 'd41d8cd98f00b204e9800998ecf8427e'},
                    'flow_pattern': {
                        'example': [
                            {'type': 'ETH_TYPE', 'ethType': '0x0800'},
                            {'type': 'IPV4_SRC', 'ip': '0.0.0.0/0'},
                            {'type': 'IP_PROTO', 'protocol': 6},
                            {'type': 'TCP_SRC', 'tcpPort': 443}
                        ]
                    },
                    'flow_class': {
                        'example': [
                            {'type': 'DPI', 'protocols': [{'type': 'YouTube'}]}
                        ]
                    },
                    'flow_quality': {
                        'example': [
                            {'type': 'BW_MIN', 'minBandwidth': '36Mbps'}
                        ]
                    }
                },
                'required': ['intent_id', 'flow_pattern', 'flow_class', 'flow_quality']
            },
            'exclude': ['patch', 'put']
        }
    }
})

# add the nodered post handler
factory.set_op(controller=nodered, op='post', func=nodered_handler)

# add the controller prototype to the factory
factory.prototype = prototype

# start the factory
factory.start_rest_api()
