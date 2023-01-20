---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Writing RSpec tests for charts

The following are notes and conventions used for creating RSpec tests for the
GitLab chart.

## Filtering RSpec tests

To aid in development it is possible to filter which tests are executed by
adding the `:focus` tag to one or more tests. With the `:focus` tag _only_
tests that have been specifically tagged will be run. This allows quick
development and testing of new code without having to wait for all the RSpec
tests to execute. The following is an example of a test that has been tagged
with`:focus`.

```ruby
describe 'some feature' do
  it 'generates output', :focus => true do
    ...
  end
end
```

The `:focus` tag can be added to `describe`, `context` or `it` blocks which
allows a test or a group of tests to be executed.

## Generating YAML from the chart

Much of the testing of the chart is that it generates the correct YAML
structure given a number of [chart inputs](#chart-inputs). This is done using
the HelmTemplate class as in the following:

```ruby
obj = HelmTemplate.new(values)
```

The resulting `obj` encodes the YAML documents returned by the `helm template`
command indexed by the [Kubernetes object `kind`](https://kubernetes.io/docs/concepts/#kubernetes-objects) and the object name (`metadata.name`). This indexed
valued is used by most of the methods to locate values within the YAML.

For example:

```ruby
obj.dig('ConfigMap/test-gitaly', 'data', 'config.toml.erb')
```

This will return the contents of the `config.toml.erb` file contained in the
`test-gitaly` ConfigMap.

NOTE:
Using the `HelmTemplate` class will always use the release name of "test"
when executing the `helm template` command.

## Chart inputs

The input parameter to the `HelmTemplate` class constructor is a dictionary
of values that represents the `values.yaml` that is used on the Helm command
line. This dictionary mirrors the YAML structure of the `values.yaml` file.

```ruby
describe 'some feature' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email:
          test@example.com
    ))
  end

  describe 'global.feature.enabled' do
    let(:values) do
      YAML.safe_load(%(
        global:
          feature:
            enabled: true
      )).deep_merge(default_values)
    end

    ...
  end
end
```

The above snippet demonstrates a common pattern of setting a number of default
values that are common across multiple tests that are then merged into the
final values that are used in the `HelmTemplate` constructor for a specific
set of tests.

## Using property merge patterns

Throughout the RSpec of this project, you will find different forms of `merge`. There are a few guidelines and considerations to take into account when choosing which to make use of.

Ruby's native `Hash.merge` will _replace_ keys in the destination, it will not deeply walk an object.
This means that all properties under a tree will be removed if the source has a matching entry.
In an attempt to address, this we've been using the [hash-deep-merge](https://rubygems.org/gems/hash-deep-merge/) gem to perform naive deep merge of YAML documents.
When _adding_ properites, this has worked well. The drawback is that this does not provide a means to cause the overwrite of nested structures.

Helm merges / coalesces configuration properties via [coalesceValues function](https://github.com/helm/helm/blob/a499b4b179307c267bdf3ec49b880e3dbd2a5591/pkg/chartutil/coalesce.go#L145-L148), which has some distinctly different behaviors to `deep_merge` as implemented here. We continue to refine how this functions within our RSpec.

**General guidelines:**

1. Be aware of and wary of the behavior of `Hash.merge`.
1. Be aware of and wary of the behavior of `Hash.deep_merge` as offered by `hash-deep-merge` gem.
1. When you need to overwrite a specific key, do so explicitly with _non-empty_ content.
1. When you need to remove a specific key, set it to `null`.
1. Do not use imperative forms (`merge!`) unless expressly needed. When doing so, comment why.

### Breakdown of considerations for merge operations

Here is a direct comparison of Ruby's `Hash.merge` versus `Hash.deep_merge` from the `hash-deep-merge` gem.

```plaintext
2.7.2 :002 > require 'yaml'
 => true
2.7.2 :003"> example = YAML.safe_load(%(
2.7.2 :004">   a:
2.7.2 :005">     b: 1
2.7.2 :006">     c: [ 1, 2, 3]
2.7.2 :007 >  ))
 => {"a"=>{"b"=>1, "c"=>[1, 2, 3]}}
2.7.2 :008"> source = YAML.safe_load(%(
2.7.2 :009">   a:
2.7.2 :010">     d: "whee"
2.7.2 :011 >  ))
 => {"a"=>{"d"=>"whee"}}
2.7.2 :012 > example.merge(source)
 => {"a"=>{"d"=>"whee"}}
```

```plaintext
2.7.2 :013 > require 'hash_deep_merge'
2.7.2 :014 > example = {"a"=>{"b"=>1, "c"=>[1, 2, 3]}}
 => {"a"=>{"b"=>1, "c"=>[1, 2, 3]}}
2.7.2 :015 > source = {"a"=>{"b"=> 2, "d"=>"whee"}}
 => {"a"=>{"b"=>2, "d"=>"whee"}}
2.7.2 :016 > example.deep_merge(source)
 => {"a"=>{"b"=>2, "c"=>[1, 2, 3], "d"=>"whee"}}
```

Let us compare the output of Ruby's `values.deep_merge(xyz)` and that of Helm's `helm template . -f xyz.yaml`, so that we can examine the differences between `deep_merge` and `coalesceValues` within Helm. The desired behavior is the equavilent of [`merge.WithOverride`](https://github.com/imdario/mergo#usage) from `github.com/imdario/mergo` Go module as used within Helm and Sprig.

The Ruby code for this is effectively:

```ruby
require 'yaml'
require 'hash_deep_merge'

values = YAML.safe_load(File.read('values.yaml'))
xyz = YAML.safe_load(File.read('xyz.yaml'))

puts values.deep_merge(xyz).to_yaml
```

```yaml
---
file: values.yaml
gitlab:
  gitaly:
    securityContext:
      user: 1000
      group: 1000
---
file: empty.yaml     # sets `securityContext: {}`
gitlab:
  gitaly:
    securityContext:
      user: 1000
      group: 1000
---
file: null.yaml      # sets `securityContext: null`
gitlab:
  gitaly:
    securityContext:
---
file: null_user.yaml # sets `securityContext.user: null`
gitlab:
  gitaly:
    securityContext:
      user:
      group: 1000
```

The Helm template contains only `{{ .Values | toYaml }}`

```yaml
---
# Source: example/templates/output.yaml
file: values.yaml
gitlab:
  gitaly:
    securityContext:
      group: 1000
      user: 1000
---
# Source: example/templates/output.yaml
file: empty.yaml     # sets `securityContext: {}`
gitlab:
  gitaly:
    securityContext:
      group: 1000
      user: 1000
---
# Source: example/templates/output.yaml
file: null.yaml      # sets `securityContext: null`
gitlab:
  gitaly: {}
---
# Source: example/templates/output.yaml
file: null_user.yaml # sets `securityContext.user: null`
gitlab:
  gitaly:
    securityContext:
      group: 1000
```

First observation: When we set an "empty" hash (`{}`), both Ruby and Helm patterns result in no change. This is because the base value, and the "new" value are both the same type. To _remove_ a hash, you must set it to `null`.

Second observation: This is a stark difference. When we set the hash to `null` in the YAML, we get slightly different results. Helm removes the entire key, but leaves the parent type intact. Ruby leaves the key present, but with `nil` value. Similar can be seen when we change an individual key. Helm removes this key while Ruby retains it in a `nil` state.

Last, but not least! Do not confuse scalars with maps. The following YAML, when merged in Ruby or Helm, will result in the array being `[]`. Neither `deep_merge` or `coalesceValues` walks into arrays. Scalar data _will be overwritten_.

```yaml
---
complex:
  array: [1,2,3]
  hash:
    item: 1
---
complex:
  array: []
  hash:
    item:
```

```yaml
---
# Ruby: puts values.deep_merge(xyz).to_yaml
complex:
  array: []
  hash:
    item:
---
# Source: example/templates/output.yaml
complex:
  array: []
  hash: {}
```

## Testing the results

The `HelmTemplate` object has a number of methods that assist with writing
RSpec tests. The following are a summary of the available methods.

- `.exit_code()`

This returns the exit code of the `helm template` command used to create the
YAML documents that instantiates the chart in the Kubernetes cluster. A
successful completion of the `helm template` will return an exit code of 0.

- `.dig(key, ...)`

Walk down the YAML document returned by the `HelmTemplate` instance and
return the value residing at the last key. If no value is found, then `nil`
is returned.

- `.labels(item)`

Return a hash of the labels for the specified object.

- `.template_labels(item)`

Return a hash of the labels used in the template structure for the specified
object. The specified object should be a Deployment, StatefulSet or a CronJob
object.

- `.annotations(item)`

Return a has of the annotations for the specified object.

- `.template_annotations(item)`

Return a hash of the annotations used in the template structure for the
specified object. The specified object should be a Deployment, StatefulSet
or a CronJob object.

- `.volumes(item)`

Return an array of all the volumes for the specified deployment object. The
returned array is a direct copy of the `volumes` key from the deployment
object.

- `.find_volume(item, volume_name)`

Return a dictionary of the specified volume from the specified deployment
object.

- `.projected_volume_sources(item, mount_name)`

Return an array of sources for the specified projected volume. The returned
array has the following structure:

```yaml
- secret:
    name: test-rails-secret
    items:
     - key: secrets.yml
       path: rails-secrets/secrets.yml
```

- `.stderr()`

Return the STDERR output from the execution of `helm template` command.

- `.values()`

Return a dictionary of all values that were used in the execution of the
`helm template` command.

## Tests that require a Kubernetes cluster

The majority of the RSpec tests execute `helm template` and then analyze
the generated YAML for the correct structures given the feature being
tested. Occasionally an RSpec test requires access to a Kubernetes cluster
with the GitLab Helm chart deployed to it. Tests that interact with the
chart deployed in a Kubernetes cluster should be placed in the `features`
directory.

If the RSpec tests are being executed and a Kubernetes cluster is not
available, then the tests in the `features` directory will be skipped. At
the start of an RSpec run `kubectl get nodes` will be checked for results
and if it returns successfully the tests in the `features` directory will
be included.

## Optimizing test speed

Each `it` block runs a Helm template, which is a time and resource intensive
operation. Given the high frequency of these blocks in our RSpec test suites,
we aim to reduce the number of `it` blocks where possible.

The [RSpec docs](https://relishapp.com/rspec/rspec-core/v/3-10/docs/helper-methods/let-and-let)
provide further explanation:

>>>
Use `let` to define a memoized helper method. The value will be cached
across multiple calls in the same example but not across examples.
>>>

For example, consider this test refactor:

Before: ~14 seconds to run

```ruby
let(:template) { HelmTemplate.new(deployments_values) }

it 'properly sets the global ingress provider when not specified' do
  expect(template.annotations('Ingress/test-webservice-default')).to include('kubernetes.io/ingress.provider' => 'global-provider')
end

it 'properly sets the local ingress provider when specified' do
  expect(template.annotations('Ingress/test-webservice-second')).to include('kubernetes.io/ingress.provider' => 'second-provider')
end
```

After: ~5 seconds to run

```ruby
let(:template) { HelmTemplate.new(deployments_values) }

it 'properly sets the ingress provider' do
  expect(template.annotations('Ingress/test-webservice-default')).to include('kubernetes.io/ingress.provider' => 'global-provider')
  expect(template.annotations('Ingress/test-webservice-second')).to include('kubernetes.io/ingress.provider' => 'second-provider')
end
```

Consolidating two `it` blocks into one leads to significant time savings because it reduces the number of calls to `helm template`.
