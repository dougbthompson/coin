import rx.functions.Action1;
import ws.wamp.jawampa.WampClient;
import ws.wamp.jawampa.WampClientBuilder;
import ws.wamp.jawampa.transport.netty.NettyWampClientConnectorProvider;
import ws.wamp.jawampa.transport.netty.NettyWampConnectionConfig;

import java.util.concurrent.TimeUnit;

public class JawampaTest {
    public static void main(String[] args) throws Exception {
        NettyWampClientConnectorProvider connectorProvider = new NettyWampClientConnectorProvider();
        NettyWampConnectionConfig connectionConfiguration = new NettyWampConnectionConfig.Builder().build();
        WampClientBuilder builder = new WampClientBuilder();
        WampClient client = builder
                .withConnectorProvider(connectorProvider)
                .withConnectionConfiguration(connectionConfiguration)
                .withUri("wss://api.poloniex.com")
                .withRealm("realm1")
                .withInfiniteReconnects()
                .withReconnectInterval(1, TimeUnit.SECONDS)
                .build();

        client.statusChanged().subscribe(new Action1<WampClient.State>() {
            @Override
            public void call(WampClient.State t1) {
                System.out.println("Session status changed to " + t1);
            }
        });

        client.open();
        Thread.sleep(100000);
    }
}
