
shared_examples_for 'Soap Read Object' do
  it { should respond_to(:info) }
  it { should respond_to(:get) }
end

shared_examples_for 'Soap CUD Object' do
  it { should respond_to(:post) }
  it { should respond_to(:patch) }
  it { should respond_to(:delete) }
end

shared_examples_for 'Soap Object' do
  it { should respond_to(:id) }
  it_behaves_like 'Soap Read Object'
  it_behaves_like 'Soap CUD Object'
end

shared_examples_for 'Soap Read Only Object' do
  it { should respond_to(:id) }
  it_behaves_like 'Soap Read Object'
end
