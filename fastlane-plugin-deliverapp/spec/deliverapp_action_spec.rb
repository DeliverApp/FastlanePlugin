describe Fastlane::Actions::DeliverappAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The deliverapp plugin is working!")

      Fastlane::Actions::DeliverappAction.run(nil)
    end
  end
end
