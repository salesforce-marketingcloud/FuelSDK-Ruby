
# Everything will be readable so test for shared from Read behavior
shared_examples_for 'Soap Read Object' do
  # begin backwards compat
  it { should respond_to :props= }
  it { should respond_to :authStub= }
  # end
  it { should respond_to :id }
  it { should respond_to :properties }
  it { should respond_to :client }
  it { should respond_to :filter }
  it { should respond_to :info }
  it { should respond_to :get }
end

shared_examples_for 'Soap CUD Object' do
  it { should respond_to :post }
  it { should respond_to :patch }
  it { should respond_to :delete }
end

shared_examples_for 'Soap Object' do
  it_behaves_like 'Soap Read Object'
  it_behaves_like 'Soap CUD Object'
end

shared_examples_for 'Soap Read Only Object' do
  it_behaves_like 'Soap Read Object'
  it { should_not respond_to :post }
  it { should_not respond_to :patch }
  it { should_not respond_to :delete }
end
