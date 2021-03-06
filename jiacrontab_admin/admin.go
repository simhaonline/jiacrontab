package admin

import (
	"jiacrontab/models"
	"jiacrontab/pkg/mailer"
	"jiacrontab/pkg/rpc"

	"sync/atomic"

	"github.com/kataras/iris/v12"
)

type Admin struct {
	cfg           atomic.Value
	initAdminUser int32
}

func (n *Admin) getOpts() *Config {
	return n.cfg.Load().(*Config)
}

func (n *Admin) swapOpts(opts *Config) {
	n.cfg.Store(opts)
}

func New(opt *Config) *Admin {
	adm := &Admin{}
	adm.swapOpts(opt)
	return adm
}

func (a *Admin) init() {
	cfg := a.getOpts()
	if err := models.InitModel(cfg.Database.DriverName, cfg.Database.DSN, cfg.App.Debug); err != nil {
		panic(err)
	}

	if models.DB().Take(&models.User{}, "group_id=?", 1).Error == nil {
		atomic.StoreInt32(&a.initAdminUser, 1)
	}

	// mail
	if cfg.Mailer.Enabled {
		mailer.InitMailer(&mailer.Mailer{
			QueueLength:    cfg.Mailer.QueueLength,
			SubjectPrefix:  cfg.Mailer.SubjectPrefix,
			From:           cfg.Mailer.From,
			Host:           cfg.Mailer.Host,
			User:           cfg.Mailer.User,
			Passwd:         cfg.Mailer.Passwd,
			FromEmail:      cfg.Mailer.FromEmail,
			DisableHelo:    cfg.Mailer.DisableHelo,
			HeloHostname:   cfg.Mailer.HeloHostname,
			SkipVerify:     cfg.Mailer.SkipVerify,
			UseCertificate: cfg.Mailer.UseCertificate,
			CertFile:       cfg.Mailer.CertFile,
			KeyFile:        cfg.Mailer.KeyFile,
			UsePlainText:   cfg.Mailer.UsePlainText,
			HookMode:       false,
		})
	}
}

func (a *Admin) Main() {

	cfg := a.getOpts()
	a.init()
	defer models.DB().Close()
	go rpc.ListenAndServe(cfg.App.RPCListenAddr, NewSrv(a))

	app := newApp(a)
	app.Run(iris.Addr(cfg.App.HTTPListenAddr))
}
