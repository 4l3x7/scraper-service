<?php return array(
    'root' => array(
        'pretty_version' => '1.0.0+no-version-set',
        'version' => '1.0.0.0',
        'type' => 'library',
        'install_path' => __DIR__ . '/../../',
        'aliases' => array(),
        'reference' => NULL,
        'name' => '__root__',
        'dev' => true,
    ),
    'versions' => array(
        '__root__' => array(
            'pretty_version' => '1.0.0+no-version-set',
            'version' => '1.0.0.0',
            'type' => 'library',
            'install_path' => __DIR__ . '/../../',
            'aliases' => array(),
            'reference' => NULL,
            'dev_requirement' => false,
        ),
        'endclothing/prometheus_client_php' => array(
            'dev_requirement' => false,
            'replaced' => array(
                0 => '*',
            ),
        ),
        'jimdo/prometheus_client_php' => array(
            'dev_requirement' => false,
            'replaced' => array(
                0 => '*',
            ),
        ),
        'lkaemmerling/prometheus_client_php' => array(
            'dev_requirement' => false,
            'replaced' => array(
                0 => '*',
            ),
        ),
        'promphp/prometheus_client_php' => array(
            'pretty_version' => 'v2.4.0',
            'version' => '2.4.0.0',
            'type' => 'library',
            'install_path' => __DIR__ . '/../promphp/prometheus_client_php',
            'aliases' => array(),
            'reference' => '7c998b3eca48d01930ccaa29d7ca4c0c3c52f045',
            'dev_requirement' => false,
        ),
    ),
);
